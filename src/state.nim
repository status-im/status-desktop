import status/types
import tables

type 
  ChatChannel = object
    name*: string

  Subscriber* = proc ()

  SignalSubscriber* = proc(p0: string)
  
  Signal = object
    signalType*: SignalType
    content*: string

var signalChannel: Channel[Signal]

type AppState* = ref object
  title*: string
  channels*: seq[ChatChannel]
  subscribers*: seq[Subscriber]
  signalSubscribers*: Table[SignalType, seq[SignalSubscriber]]
  

proc newAppState*(): AppState =
  result = AppState(
    title: "hello",
    signalSubscribers: initTable[SignalType, seq[SignalSubscriber]]()
  )
  signalChannel.open()

proc subscribe*(self: AppState, subscriber: Subscriber) =
  self.subscribers.add(subscriber)

proc dispatch*(self: AppState) =
  for subscriber in self.subscribers:
    subscriber()

proc addChannel*(self: AppState, name: string) =
    self.channels.add(ChatChannel(name: name))
    self.dispatch()

#####################
# Signal Handling

proc processSignals*(self: AppState) =
  ## Polls the signal channel and push the message to each subscriber
  {.gcsafe.}:
    while(true):
      let tried = signalChannel.tryRecv()
      if tried.dataAvailable and self.signalSubscribers.hasKey(tried.msg.signalType):
        for subscriber in self.signalSubscribers[tried.msg.signalType]:
          subscriber(tried.msg.content)
  defer:
    signalChannel.close()

proc addToChannel(s: Signal) {.thread.} =
  signalChannel.send(s)

proc nextSignal*(self: AppState, signalType: SignalType, jsonMessage: string)  = 
  ## This is called by the signal handler for each signal received and 
  ## adds it to the signal channel for being consumed by the SignalSubscribers
  let signal: Signal = Signal(signalType: signalType, content: jsonMessage)
  var worker: Thread[Signal]
  createThread(worker, addToChannel, signal)
  worker.joinThread()

proc onSignal*(self: AppState, signalType: SignalType, subscriber: SignalSubscriber) =
  ## Register a callback that will be executed once
  ## a signal is received from status-go
  if not self.signalSubscribers.hasKey(signalType):
    self.signalSubscribers[signalType] = @[]
  self.signalSubscribers[signalType].add(subscriber)