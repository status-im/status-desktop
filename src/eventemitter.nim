import # system libs
  tables

import # deps
  uuids

type 
  Args* = ref object of RootObj # ...args
  Handler* = proc (args: Args) {.closure.} # callback function type
  EventEmitter* = ref object
    events: Table[string, Table[UUID, Handler]]

proc createEventEmitter*(): EventEmitter = 
  result.new
  result.events = initTable[string, Table[UUID, Handler]]()


proc on(this: EventEmitter, name: string, handlerId: UUID, handler: Handler): void =
  if this.events.hasKey(name):
    this.events[name].add handlerId, handler
    return
  
  this.events[name] = [(handlerId, handler)].toTable

proc on*(this: EventEmitter, name: string, handler: Handler): void = 
  var uuid: UUID
  this.on(name, uuid, handler)

proc once*(this:EventEmitter, name:string, handler:Handler): void =
  var handlerId = genUUID()
  this.on(name, handlerId) do(a: Args):
    handler(a)
    this.events[name].del handlerId

proc emit*(this:EventEmitter, name:string, args:Args): void  =
  if this.events.hasKey(name):
    for (id, handler) in this.events[name].pairs:
      handler(args)

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
    evts.emit("ready", ReadyArgs(text:"Hello, World"))
