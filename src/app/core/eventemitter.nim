import # system libs
  tables

import # deps
  uuids

type
  Args* = ref object of RootObj # ...args
  Handler* = proc(args: Args) {.closure.} # callback function type
  EventEmitter* = ref object
    events: Table[string, OrderedTable[UUID, Handler]]

proc createEventEmitter*(): EventEmitter =
  result.new
  result.events = initTable[string, OrderedTable[UUID, Handler]]()

proc on(this: EventEmitter, name: string, handlerId: UUID, handler: Handler): void =
  if this.events.hasKey(name):
    this.events[name][handlerId] = handler
    return

  this.events[name] = [(handlerId, handler)].toOrderedTable

proc on*(this: EventEmitter, name: string, handler: Handler): void =
  var handlerId = genUUID()
  this.on(name, handlerId, handler)

proc once*(this: EventEmitter, name: string, handler: Handler): void =
  var handlerId = genUUID()
  this.on(name, handlerId) do(a: Args):
    handler(a)
    this.events[name].del handlerId

proc onUsingUUID*(
    this: EventEmitter, handlerId: UUID, name: string, handler: Handler
): void =
  this.on(name, handlerId, handler)

proc onWithUUID*(this: EventEmitter, name: string, handler: Handler): UUID =
  var handlerId = genUUID()
  this.on(name, handlerId, handler)
  return handlerId

proc disconnect*(this: EventEmitter, handlerId: UUID) =
  for k, v in this.events:
    if v.hasKey(handlerId):
      this.events[k].del handlerId

proc emit*(this: EventEmitter, name: string, args: Args): void =
  if this.events.hasKey(name):
    # collect the handlers before executing them
    # because of 'once' proc, we also mutate
    # this.events. This can cause unexpected behaviour
    # while having an iterator on this.events
    var handlers: seq[Handler] = @[]
    for (id, handler) in this.events[name].pairs:
      handlers.add(handler)

    for i in 0 .. len(handlers) - 1:
      handlers[i](args)

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
    evts.emit("ready", ReadyArgs(text: "Hello, World"))
