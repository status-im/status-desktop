import # vendor libs
  nimqml, json_serialization

import # status-desktop libs
  ./common

type
  QObjectTaskArg* = ref object of TaskArg
    vptr*: uint
    slot*: string

proc finish*[T](arg: QObjectTaskArg, payload: T) =
  signal_handler(cast[pointer](arg.vptr), cstring(Json.encode(payload)), cstring(arg.slot))

proc finish*(arg: QObjectTaskArg, payload: string) =
  signal_handler(cast[pointer](arg.vptr), cstring(payload), cstring(arg.slot))
