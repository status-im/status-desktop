import eventemitter

import # deps
  uuids

type
  UniqueUUIDEventEmitter* = ref object
    events: EventEmitter
    handlerId: UUID

proc initUniqueUUIDEventEmitter*(events: EventEmitter): UniqueUUIDEventEmitter =
  result = UniqueUUIDEventEmitter()
  result.events = events
  result.handlerId = genUUID()

proc on*(self: UniqueUUIDEventEmitter, name: string, handler: Handler): void =
  self.events.onUsingUUID(self.handlerId, name, handler)

proc disconnect*(self: UniqueUUIDEventEmitter) =
  self.events.disconnect(self.handlerId)

proc eventsEmitter*(self: UniqueUUIDEventEmitter): EventEmitter =
    return self.events