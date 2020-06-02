import algorithm, json, random, math
import libstatus/core as status_core
import libstatus/chat as status_chat
import libstatus/mailservers as status_mailservers
import tables
import sets
import chronicles
import eventemitter
import sequtils


logScope:
  topics = "mailserver-model"

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
    events*: EventEmitter
    nodes*: Table[string, MailserverStatus]
    selectedMailserver*: string
    topics*: HashSet[string]


proc cmpMailserverReply(x, y: (string, int)): int =
  if x[1] > y[1]: 1
  elif x[1] == y[1]: 0
  else: -1

proc poolSize(fleetSize: int): int = ceil(fleetSize / 4).int

proc newMailserverModel*(events: EventEmitter): MailserverModel =
  result = MailserverModel()
  result.events = events
  result.nodes = initTable[string, MailserverStatus]()
  result.selectedMailserver = ""
  result.topics = initHashSet[string]()

proc addTopics*(self: MailserverModel, topics: seq[string]) =
  for t in topics: self.topics.incl(t)

proc trustPeer*(self: MailserverModel, enode:string) = 
  markTrustedPeer(enode)
  self.nodes[enode] = MailserverStatus.Trusted
  if self.selectedMailserver == enode:
    debug "Mailserver available", enode
    self.events.emit("mailserverAvailable", Args())

proc selectedServerStatus*(self: MailserverModel): MailserverStatus =
  if self.selectedMailserver == "": MailserverStatus.Unknown
  else: self.nodes[self.selectedMailserver]

proc isSelectedMailserverAvailable*(self:MailserverModel): bool =
  self.nodes[self.selectedMailserver] == MailserverStatus.Trusted

proc connect*(self: MailserverModel, enode: string) =
  debug "Connecting to mailserver", enode
  self.selectedMailserver = enode
  if self.nodes.hasKey(enode):
    if self.nodes[enode] == MailserverStatus.Connected:
      self.trustPeer(enode)
  else:
    self.nodes[enode] = MailserverStatus.Connecting
    addPeer(enode)
    # TODO: check if connection is made after a connection timeout?
  echo status_mailservers.update(enode)

proc peerSummaryChange*(self: MailserverModel, peers: seq[string]) =
  # TODO: check if peer received is a mailserver from the list before doing any operation

  for peer in self.nodes.keys: 
    if not peers.contains(peer): 
      self.nodes[peer] = MailserverStatus.Disconnected
      self.events.emit("peerDisconnected", MailserverArg(peer: peer))
    # TODO: reconnect peer up to N times on 'peerDisconnected'
  
  # TODO: this should come from settings
  var knownMailservers = initHashSet[string]()
  for m in getMailservers():
    knownMailservers.incl m[1]

  for peer in peers:
    if not knownMailservers.contains(peer): continue
    if self.nodes.hasKey(peer) and self.nodes[peer] == MailserverStatus.Trusted: continue
    self.nodes[peer] = MailserverStatus.Connected
    self.events.emit("peerConnected", MailserverArg(peer: peer))


proc init*(self: MailserverModel) =
  self.events.on("peerConnected") do(e: Args):
    let arg = MailserverArg(e)
    self.trustPeer(arg.peer)


  #TODO: connect to current mailserver from the settings

  # or setup a random one:
  let mailserversReply = parseJson(status_mailservers.ping(500))["result"]
  var availableMailservers:seq[(string, int)] = @[]

  for reply in mailserversReply: 
    if(reply["error"].kind != JNull): continue # The results with error are ignored
    availableMailservers.add((reply["address"].getStr, reply["rttMs"].getInt))
  
  availableMailservers.sort(cmpMailserverReply)
  
  # Picks a random mailserver amongs the ones with the lowest latency
  # The pool size is 1/4 of the mailservers were pinged successfully
  randomize()
  let mailServer = availableMailservers[rand(poolSize(availableMailservers.len))][0]
  self.connect(mailserver) 

proc requestMessages*(self: MailserverModel) =
  debug "Requesting messages from", mailserver=self.selectedMailserver
  let generatedSymKey = status_chat.generateSymKeyFromPassword()
  status_chat.requestMessages(toSeq(self.topics), generatedSymKey, self.selectedMailserver, 1000)

