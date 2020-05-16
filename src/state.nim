import status/types
import tables

##########################################################
## warning: this file is still very much in flux
##########################################################

type 
  ChatChannel = object
    name*: string

  Subscriber* = proc ()

type AppState* = ref object
  title*: string
  channels*: seq[ChatChannel]
  subscribers*: seq[Subscriber]

proc newAppState*(): AppState =
  result = AppState(title: "hello")

proc subscribe*(self: AppState, subscriber: Subscriber) =
  self.subscribers.add(subscriber)

proc dispatch*(self: AppState) =
  for subscriber in self.subscribers:
    subscriber()

proc addChannel*(self: AppState, name: string) =
    self.channels.add(ChatChannel(name: name))
    self.dispatch()
