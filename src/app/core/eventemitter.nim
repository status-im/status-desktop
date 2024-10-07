import # system libs
  tables

import # deps
  uuids

import NimQml

type
  Args* = ref object of RootObj # ...args
  Handler* = proc (args: Args) {.closure.} # callback function type

QtObject:
  type EventEmitter* = ref object of QObject
    events: Table[string, OrderedTable[UUID, Handler]]
    collectedArgs: Table[string, Args]


  proc delete*(self: EventEmitter) =
    self.QObject.delete

  proc setup(self: EventEmitter) =
    self.QObject.setup

  proc createEventEmitter*(): EventEmitter =
    new(result, delete)
    result.setup
    result.events = initTable[string, OrderedTable[UUID, Handler]]()
    result.collectedArgs = initTable[string, Args]()
    signalConnect(result, "trigger(QString, QString, QString)", result, "handleTrigger(QString, QString, QString)", 2)
    signalConnect(result, "clearArg(QString)", result, "handleClearArg(QString)", 2)

  proc on(this: EventEmitter, name: string, handlerId: UUID, handler: Handler): void =
    if this.events.hasKey(name):
      this.events[name][handlerId] = handler
      return

    this.events[name] = [(handlerId, handler)].toOrderedTable

  proc on*(this: EventEmitter, name: string, handler: Handler): void =
    var handlerId = genUUID()
    this.on(name, handlerId, handler)

  proc once*(this:EventEmitter, name:string, handler:Handler): void =
    var handlerId = genUUID()
    this.on(name, handlerId) do(a: Args):
      handler(a)
      this.events[name].del handlerId

  proc onUsingUUID*(this: EventEmitter, handlerId: UUID, name: string, handler: Handler): void =
    this.on(name, handlerId, handler)

  proc onWithUUID*(this: EventEmitter, name: string, handler: Handler): UUID =
    var handlerId = genUUID()
    this.on(name, handlerId, handler)
    return handlerId

  proc disconnect*(this: EventEmitter, handlerId: UUID) =
    for k, v in this.events:
      if v.hasKey(handlerId):
        this.events[k].del handlerId

  proc trigger(this: EventEmitter, name: string, handlerId: string, argsId: string) {.signal.}
  proc clearArg(this: EventEmitter, argsId: string) {.signal.}

  proc handleTrigger(this: EventEmitter, name: string, handlerId: string, argsId: string) {.slot.} =
    #echo "EventEmitter: trigger", name, handlerId, argsId
    if not this.collectedArgs.hasKey(argsId):
      echo "EventEmitter: args not found", argsId
      return

    if not this.events.hasKey(name):
      echo "EventEmitter: event not found"
      return

    let handlerUUID = handlerId.parseUUID()
    if not this.events[name].hasKey(handlerUUID):
      echo "EventEmitter: handler not found"
      return

    let args = this.collectedArgs[argsId]
    this.events[name][handlerUUID](args)

  proc handleClearArg(this: EventEmitter, argsId: string) {.slot.} =
    if this.collectedArgs.hasKey(argsId):
      this.collectedArgs.del argsId
      #echo "EventEmitter: clearedArgs", argsId

  proc emit*(this:EventEmitter, name:string, args:Args): void  =

    if this.events.hasKey(name):
      # collect the handlers before executing them
      # because of 'once' proc, we also mutate
      # this.events. This can cause unexpected behaviour
      # while having an iterator on this.events
      var handlers: seq[string] = @[]
      for (id, handler) in this.events[name].pairs:
        handlers.add($id)

      if handlers.len == 0:
        return

      let argsId = $(genUUID())
      this.collectedArgs[argsId] = args
      #echo "EventEmitter: collectedArgs", name, argsId, this.collectedArgs.hasKey(argsId)

      for i in 0..len(handlers)-1:
        #echo "EventEmitter: emit", name, handlers[i], argsId
        this.trigger(name, handlers[i], argsId)
      
      this.clearArg(argsId)

when isMainModule:
  block:
    type ReadyArgs = ref object of Args
      text: string
    var evts = createEventEmitter()
    evts.on("ready") do(a: Args):
      var args = ReadyArgs(a)
      echo args.text, ": from [1st] handler"
    evts.once("ready") do(a: Args):
      var args = ReadyArgs(a)
      echo args.text, ": from [2nd] handler"
    evts.emit("ready", ReadyArgs(text:"Hello, World"))
