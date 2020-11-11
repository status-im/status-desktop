import algorithm, json, random, math, os, tables, sets, chronicles, sequtils, locks, sugar, times
import libstatus/core as status_core
import libstatus/chat as status_chat
import libstatus/settings as status_settings
import libstatus/types
import libstatus/mailservers as status_mailservers
import ../eventemitter
import fleet


# How do mailserver should work ?
#
# - We send a request to the mailserver, we are only interested in the
#   messages since `last-request` up to the last seven days
#   and the last 24 hours for topics that were just joined 
# - The mailserver doesn't directly respond to the request and
#   instead we start receiving messages in the filters for the requested
#   topics.
# - If the mailserver was not ready when we tried for instance to request
#   the history of a topic after joining a chat, the request will be done
#   as soon as the mailserver becomes available 

logScope:
  topics = "mailserver-model"

var nodesLock: Lock
var activeMailserverLock: Lock


type
  MailserverArg* = ref object of Args
    peer*: string

  MailserverStatus* = enum
    Unknown = -1,
    Disconnected = 0,
    Connecting = 1
    Connected = 2, 
    Trusted = 3,

  MailserverModel* = ref object
    mailservers*: seq[string]
    events*: EventEmitter
    nodes*: Table[string, MailserverStatus]
    activeMailserver*: string
    topics*: HashSet[string]
    lastConnectionAttempt*: float
    fleet*: FleetModel


proc cmpMailserverReply(x, y: (string, int)): int =
  if x[1] > y[1]: 1
  elif x[1] == y[1]: 0
  else: -1


proc poolSize(fleetSize: int): int = ceil(fleetSize / 4).int


var mailserverModel: MailServerModel
var modelLock: Lock
var connThread: Thread[void]


proc newMailserverModel*(fleet: FleetModel, events: EventEmitter): MailserverModel =
  result = MailserverModel()
  result.events = events
  result.fleet = fleet
  result.nodes = initTable[string, MailserverStatus]()
  result.activeMailserver = ""
  
  mailserverModel = result

  modelLock.initLock()
  nodesLock.initLock()
  activeMailserverLock.initLock()


proc trustPeer(self: MailserverModel, enode:string) = 
  markTrustedPeer(enode)
  self.nodes[enode] = MailserverStatus.Trusted


proc isActiveMailserverAvailable*(self:MailserverModel): bool =
  activeMailserverLock.acquire()
  nodesLock.acquire()

  if not self.nodes.hasKey(self.activeMailserver): 
    result = false
  else:
    result = self.nodes[self.activeMailserver] == MailserverStatus.Trusted

  nodesLock.release()
  activeMailserverLock.release()


proc connect(self: MailserverModel, enode: string) =
  debug "Connecting to mailserver", enode=enode.substr[enode.len-40..enode.len-1]

  # TODO: this should come from settings
  var knownMailservers = initHashSet[string]()
  for m in self.mailservers:
    knownMailservers.incl m
  if not knownMailservers.contains(enode): 
    warn "Mailserver not known", enode
    return

  activeMailserverLock.acquire()
  nodesLock.acquire()

  self.activeMailserver = enode

  # Adding a peer and marking it as trusted can't be executed sync, because
  # There's a delay between requesting a peer being added, and a signal being 
  # received after the peer was added. So we first set the peer status as 
  # Connecting and once a peerConnected signal is received, we mark it as 
  # Connected and then as Trusted

  # Attempt to connect to mailserver by adding it as a peer
  self.nodes[enode] = MailserverStatus.Connecting
  addPeer(enode)
  self.lastConnectionAttempt = cpuTime()

  nodesLock.release()
  activeMailserverLock.release()




proc peerSummaryChange*(self: MailserverModel, peers: seq[string]) =
  # When a node is added as a peer, or disconnected
  # a DiscoverySummary signal is emitted. In here we
  # change the status of the nodes the app is connected to
  # Connected / Disconnected and emit peerConnected / peerDisconnected
  # events.
  var mailserverAvailable = false
  withLock nodesLock:
    for knownPeer in self.nodes.keys:
      if not peers.contains(knownPeer) and self.nodes[knownPeer] != MailserverStatus.Disconnected: 
        debug "Peer disconnected", peer=knownPeer
        self.nodes[knownPeer] = MailserverStatus.Disconnected
        self.events.emit("peerDisconnected", MailserverArg(peer: knownPeer))
        withLock activeMailserverLock:
          if self.activeMailserver == knownPeer:
            warn "Active mailserver disconnected!", peer = knownPeer
            self.activeMailserver = ""
    
    for peer in peers:
      if self.nodes.hasKey(peer) and (self.nodes[peer] == MailserverStatus.Connected or self.nodes[peer] == MailserverStatus.Trusted): continue
      debug "Peer connected", peer
      self.nodes[peer] = MailserverStatus.Connected
      self.events.emit("peerConnected", MailserverArg(peer: peer))

      withLock activeMailserverLock:
        if peer == self.activeMailserver:
          if self.nodes.hasKey(self.activeMailserver):
            self.trustPeer(peer)
            if self.activeMailserver == peer:
              mailserverAvailable = true
          
          status_mailservers.update(peer)

  if mailserverAvailable:
    debug "Mailserver available"
    self.events.emit("mailserverAvailable", Args())


proc requestMessages*(self: MailserverModel, topics: seq[string], fromValue: int64 = 0, toValue: int64 = 0, force: bool = false) =
  withLock activeMailserverLock:
    debug "Requesting messages from", mailserver=self.activeMailserver
    let generatedSymKey = status_chat.generateSymKeyFromPassword()
    status_mailservers.requestMessages(topics, generatedSymKey, self.activeMailserver, 1000, fromValue, toValue, force)

proc getMailserverTopics*(self: MailserverModel): seq[MailserverTopic] =
  let response = status_mailservers.getMailserverTopics()
  let topics = parseJson(response)["result"]
  result = @[]
  if topics.kind != JNull:
    for topic in topics:
      result.add(MailserverTopic(
        topic: topic["topic"].getStr,
        discovery: topic["discovery?"].getBool,
        negotiated: topic["negotiated?"].getBool,
        chatIds: topic["chat-ids"].to(seq[string]),
        lastRequest: topic["last-request"].getInt
      ))


proc getMailserverTopicsByChatId*(self: MailserverModel, chatId: string): seq[MailServerTopic] =
  result = self.getMailserverTopics()
      .filter(topic => topic.chatIds.contains(chatId))

proc addMailserverTopic*(self: MailserverModel, topic: MailserverTopic) =
  discard status_mailservers.addMailserverTopic(topic)


proc findNewMailserver(self: MailserverModel) =
  warn "Finding a new mailserver..."
  
  let mailserversReply = parseJson(status_mailservers.ping(self.mailservers, 500))["result"]
  
  var availableMailservers:seq[(string, int)] = @[]
  for reply in mailserversReply: 
    if(reply["error"].kind != JNull): continue # The results with error are ignored
    availableMailservers.add((reply["address"].getStr, reply["rttMs"].getInt))
  availableMailservers.sort(cmpMailserverReply)

  # No mailservers where returned... do nothing.
  if availableMailservers.len == 0: return

  # Picks a random mailserver amongs the ones with the lowest latency
  # The pool size is 1/4 of the mailservers were pinged successfully
  randomize()

  let mailServer = availableMailservers[rand(poolSize(availableMailservers.len - 1))][0]

  self.connect(mailserver) 


proc cycleMailservers(self: MailserverModel) =
  warn "Automatically switching mailserver"
  withLock activeMailserverLock:
    if self.activeMailserver != "":
      warn "Disconnecting Actime Mailserver", peer=self.activeMailserver
      withLock nodesLock:
        self.nodes[self.activeMailserver] = MailserverStatus.Disconnected
        removePeer(self.activeMailserver)
      self.activeMailserver = ""
  self.findNewMailserver()

proc checkConnection() {.thread.} =
  {.gcsafe.}:
    #TODO: connect to current mailserver from the settings

    # or setup a random mailserver:
    let sleepDuration = 10000
    while true:
      debug "Verifying mailserver connection state..."
      withLock modelLock: 
        # TODO: have a timeout for reconnection before changing to a different server
        if not mailserverModel.isActiveMailserverAvailable:
          mailserverModel.cycleMailservers()
      sleep(sleepDuration)


proc init*(self: MailserverModel) =
  debug "MailserverModel::init()"
  self.mailservers = toSeq(self.fleet.config.getMailservers(status_settings.getFleet()).values)
  connThread.createThread(checkConnection)
  