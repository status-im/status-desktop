import # vendor libs
  NimQml, json_serialization

import # status-desktop libs
  ../../../../eventemitter

type
  MailserverEvents* = ref object
    vptr: ByteAddress
  MailserverArgs* = ref object of Args
    peer*: string

const EVENTS_SLOT = "receiveEvent"

proc newMailserverEvents*(vptr: ByteAddress): MailserverEvents =
  new(result)
  result.vptr = vptr

proc emit*(self: MailserverEvents, event: string, arg: MailserverArgs) =
  let payload: tuple[event: string, arg: MailserverArgs] = (event, arg)
  signal_handler(cast[pointer](self.vptr), Json.encode(payload), EVENTS_SLOT)