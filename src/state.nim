

type Channel = object
    name*: string
type
    Subscriber* = proc ()

type AppState* = ref object
    title*: string
    channels*: seq[Channel]
    subscribers*: seq[Subscriber]

proc newAppState*(): AppState =
    result = AppState(title: "hello")

proc subscribe*(self: AppState, subscriber: Subscriber) =
  self.subscribers.add(subscriber)

proc dispatch*(self: AppState) =
  for subscriber in self.subscribers:
    subscriber()

proc addChannel*(self: AppState, name: string) =
    self.channels.add(Channel(name: name))
    self.dispatch()
