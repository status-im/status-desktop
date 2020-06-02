import algorithm, json, random, math
import libstatus/core as status_core
import libstatus/chat as status_chat
import libstatus/mailservers as status_mailservers
import tables
import chronicles
import eventemitter


logScope:
  topics = "mailserver-model"

type
  MailserverArg* = ref object of Args
    peer*: string

  MailserverStatus* = enum
    Disconnected = 0,
    Connecting = 1
    Connected = 2, 
    Trusted = 3,

  MailserverModel* = ref object
    events*: EventEmitter
    nodes*: Table[string, MailserverStatus]


proc cmpMailserverReply(x, y: (string, int)): int =
  if x[1] > y[1]: 1
  elif x[1] == y[1]: 0
  else: -1

proc poolSize(fleetSize: int): int = ceil(fleetSize / 4).int

proc newMailserverModel*(events: EventEmitter): MailserverModel =
  result = MailserverModel()
  result.events = events
  result.nodes = initTable[string, MailserverStatus]()

proc trustPeer*(self: MailserverModel, enode:string) = 
  markTrustedPeer(enode)

proc connect*(self: MailserverModel, enode: string) =
  if self.nodes.hasKey(enode):
    if self.nodes[enode] == MailserverStatus.Connected:
      self.trustPeer(enode)
  else:
    self.nodes[enode] = MailserverStatus.Connecting
    addPeer(enode)
    # TODO: check if connection is made after a connection timeout?
  
  echo status_mailservers.update(enode)

proc peerSummaryChange*(self: MailserverModel, peers: seq[string]) =
  for peer in self.nodes.keys: 
    if not peers.contains(peer): 
      self.nodes[peer] = MailserverStatus.Disconnected
      self.events.emit("peerDisconnected", MailserverArg(peer: peer))
    # TODO: reconnect peer up to N times on 'peerDisconnected'
  
  for peer in peers:
    if not self.nodes.hasKey(peer) or self.nodes[peer] == MailserverStatus.Disconnected: 
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


