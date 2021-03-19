import # vendor libs
  NimQml, json_serialization

import # status-desktop libs
  ./common

type
  QObjectTaskArg* = ref object of TaskArg
    vptr*: ByteAddress
    slot*: string

proc finish*[T](arg: QObjectTaskArg, payload: T) =
  signal_handler(cast[pointer](arg.vptr), Json.encode(payload), arg.slot)

proc finish*(arg: QObjectTaskArg, payload: string) =
  signal_handler(cast[pointer](arg.vptr), payload, arg.slot)
