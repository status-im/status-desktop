import
  algorithm, chronos, chronicles, json, math, os, random, sequtils, sets,
  tables, strutils
from times import cpuTime

import
  status/statusgo_backend/settings as status_settings,
  status/statusgo_backend/chat as status_chat,
  status/statusgo_backend/mailservers as status_mailservers,
  status/statusgo_backend/core as status_core,
  status/fleet,
  ./events as mailserver_events

logScope:
  topics = "mailserver model"

################################################################################
##                                                                            ##
## NOTE: MailserverModel runs on a separate (long-running) thread             ##
##                                                                            ##
## How do mailservers work ?                                                  ##
##                                                                            ##
## - We send a request to the mailserver, we are only interested in the       ##
##   messages since `last-request` up to the last seven days                  ##
##   and the last 24 hours for topics that were just joined                   ##
## - The mailserver doesn't directly respond to the request and               ##
##   instead we start receiving messages in the filters for the requested     ##
##   topics.                                                                  ##
## - If the mailserver was not ready when we tried for instance to request    ##
##   the history of a topic after joining a chat, the request will be done    ##
##   as soon as the mailserver becomes available                              ##
##                                                                            ##
################################################################################
type
  MailserverModel* = ref object
    mailservers*: seq[string]
    events*: MailserverEvents
    nodes*: Table[string, MailserverStatus]
    activeMailserver*: string
    lastConnectionAttempt*: float
    wakuVersion*: int

  MailserverStatus* = enum
    Unknown = -1,
    Disconnected = 0,
    Connecting = 1
    Connected = 2, 

proc peerIdFromMultiAddress(nodeAddr: string): string =
  let multiAddressParts = nodeAddr.split("/")
  return multiAddressParts[multiAddressParts.len - 1]

proc cmpMailserverReply(x, y: (string, int)): int =
  if x[1] > y[1]: 1
  elif x[1] == y[1]: 0
  else: -1

proc poolSize(fleetSize: int): int = ceil(fleetSize / 4).int

proc newMailserverModel*(vptr: ByteAddress): MailserverModel =
  result = MailserverModel()
  result.events = newMailserverEvents(vptr)
  result.nodes = initTable[string, MailserverStatus]()
  result.activeMailserver = ""
  result.mailservers = @[]

proc init*(self: MailserverModel) =
  trace "MailserverModel::init()"
  
  self.wakuVersion = status_settings.getWakuVersion()

  let nodeConfig = status_settings.getNodeConfig()
  if self.wakuVersion == 2:
    # TODO:
    # Instead of obtaining the waku2 fleet from fleet.json, expose a method in status-go that will
    # return the list of store nodes. (The cluster config can ontain dns-discovery urls so it cannot be
    # used to populate the list of mailservers)
    let fleets = if defined(windows) and defined(production):
      "/../resources/fleets.json"
    else:
      "/../fleets.json"
    let fleetConfig = readFile(joinPath(getAppDir(), fleets))
    let fleet = newFleetModel(fleetConfig)
    self.mailservers = toSeq(fleet.config.getMailservers(status_settings.getFleet(), true).values)
  else:
    for mailserver in nodeConfig["ClusterConfig"]["TrustedMailServers"].getElems():
      self.mailservers.add(mailserver.getStr())

  for mailserver in status_settings.getMailservers().getElems():
    self.mailservers.add(mailserver["address"].getStr())


proc getActiveMailserver*(self: MailserverModel): string = self.activeMailserver

proc isActiveMailserverAvailable*(self: MailserverModel): bool =
  if not self.nodes.hasKey(self.activeMailserver): 
    result = false
  else:
    result = self.nodes[self.activeMailserver] == MailserverStatus.Connected

proc connect(self: MailserverModel, nodeAddr: string) =
  debug "Connecting to mailserver", nodeAddr
  var connected = false
  # TODO: this should come from settings
  var knownMailservers = initHashSet[string]()
  for m in self.mailservers:
    knownMailservers.incl m
  if not knownMailservers.contains(nodeAddr): 
    warn "Mailserver not known", nodeAddr
    return

  self.activeMailserver = if self.wakuVersion == 2: peerIdFromMultiAddress(nodeAddr) else: nodeAddr
  self.events.emit("mailserver:changed", MailserverArgs(peer: nodeAddr))

  # Adding a peer and marking it as connected can't be executed sync in WakuV1, because
  # There's a delay between requesting a peer being added, and a signal being 
  # received after the peer was added. So we first set the peer status as 
  # Connecting and once a peerConnected signal is received, we mark it as 
  # Connected

  if self.nodes.hasKey(self.activeMailserver) and self.nodes[self.activeMailserver] == MailserverStatus.Connected:
    connected = true
  else:
    # Attempt to connect to mailserver by adding it as a peer
    if self.wakuVersion == 2:
      if status_core.dialPeer(nodeAddr): # WakuV2 dial is sync (should it be async?)
        discard status_mailservers.setMailserver(self.activeMailserver)
        self.nodes[self.activeMailserver] = MailserverStatus.Connected
        connected = true
    else:
      status_mailservers.update(nodeAddr)
      self.nodes[nodeAddr] = MailserverStatus.Connecting
      
    self.lastConnectionAttempt = cpuTime()

  if connected:
    info "Mailserver available"
    self.events.emit("mailserverAvailable", MailserverArgs())

proc peerSummaryChange*(self: MailserverModel, peers: seq[string]) =
  # When a node is added as a peer, or disconnected
  # a DiscoverySummary signal is emitted. In here we
  # change the status of the nodes the app is connected to
  # Connected / Disconnected and emit peerConnected / peerDisconnected
  # events.

  var mailserverAvailable = false
  for knownPeer in self.nodes.keys:
    if not peers.contains(knownPeer) and (self.nodes[knownPeer] == MailserverStatus.Connected or (self.nodes[knownPeer] == MailserverStatus.Connecting and (cpuTime() - self.lastConnectionAttempt) > 8)): 
      info "Peer disconnected", peer=knownPeer
      self.nodes[knownPeer] = MailserverStatus.Disconnected
      self.events.emit("peerDisconnected", MailserverArgs(peer: knownPeer))
      if self.activeMailserver == knownPeer:
        warn "Active mailserver disconnected!", peer = knownPeer
        self.activeMailserver = ""
  
  for peer in peers:
    if self.nodes.hasKey(peer) and (self.nodes[peer] == MailserverStatus.Connected): continue
    info "Peer connected", peer
    self.nodes[peer] = MailserverStatus.Connected
    self.events.emit("peerConnected", MailserverArgs(peer: peer))

    if peer == self.activeMailserver:
      if self.nodes.hasKey(self.activeMailserver):
        if self.activeMailserver == peer:
          mailserverAvailable = true
      
  if mailserverAvailable:
    info "Mailserver available"
    self.events.emit("mailserverAvailable", MailserverArgs())

proc requestMessages*(self: MailserverModel) =
  info "Requesting messages from", mailserver=self.activeMailserver
  discard status_mailservers.requestAllHistoricMessages()

proc requestStoreMessages*(self: MailserverModel, topics: seq[string], fromValue: int64 = 0, toValue: int64 = 0, force: bool = false) =
  info "Requesting messages from", mailserver=self.activeMailserver
  let generatedSymKey = status_chat.generateSymKeyFromPassword()
  status_mailservers.requestStoreMessages(topics, generatedSymKey, self.activeMailserver, 1000, fromValue, toValue, force)

proc requestMoreMessages*(self: MailserverModel, chatId: string) =
  info "Requesting more messages from", mailserver=self.activeMailserver, chatId=chatId
  discard status_mailservers.syncChatFromSyncedFrom(chatId)

proc fillGaps*(self: MailserverModel, chatId: string, messageIds: seq[string]) =
  info "Requesting fill gaps from", mailserver=self.activeMailserver, chatId=chatId
  discard status_mailservers.fillGaps(chatId, messageIds)

proc findNewMailserver(self: MailserverModel) =
  warn "Finding a new mailserver...", wakuVersion=self.wakuVersion
  
  let mailserversReply = parseJson(status_mailservers.ping(self.mailservers, 500, self.wakuVersion == 2))["result"]
  
  var availableMailservers:seq[(string, int)] = @[]
  for reply in mailserversReply: 
    if(reply["error"].kind != JNull): continue # The results with error are ignored
    availableMailservers.add((reply["address"].getStr, reply["rttMs"].getInt))
  availableMailservers.sort(cmpMailserverReply)

  # No mailservers where returned... do nothing.
  if availableMailservers.len == 0: 
    warn "No mailservers available"
    return

  # Picks a random mailserver amongs the ones with the lowest latency
  # The pool size is 1/4 of the mailservers were pinged successfully
  randomize()

  let mailServer = availableMailservers[rand(poolSize(availableMailservers.len - 1))][0]

  self.connect(mailserver)

proc cycleMailservers(self: MailserverModel) =
  warn "Automatically switching mailserver"
  if self.activeMailserver != "":
    info "Disconnecting active mailserver", peer=self.activeMailserver
    self.nodes[self.activeMailserver] = MailserverStatus.Disconnected
    if self.wakuVersion == 2:
      dropPeerByID(self.activeMailserver)
    else:
      removePeer(self.activeMailserver)
    self.activeMailserver = ""
  self.findNewMailserver()

proc checkConnection*(self: MailserverModel) {.async.} =
  while true:
    info "Verifying mailserver connection state..."
    let pinnedMailserver = status_settings.getPinnedMailserver()
    if self.wakuVersion == 1 and pinnedMailserver != "" and self.activeMailserver != pinnedMailserver:
      # connect to current mailserver from the settings
      self.mailservers.add(pinnedMailserver)
      self.connect(pinnedMailserver) 
    else:
      # or setup a random mailserver:
      if not self.isActiveMailserverAvailable:
        # TODO: have a timeout for reconnection before changing to a different server
        self.cycleMailservers()
    await sleepAsync(10.seconds)
