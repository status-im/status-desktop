{.used.}

import json

type StatusUpdateType* {.pure.}= enum
  Unknown = 0,
  Online = 1, 
  DoNotDisturb = 2

type StatusUpdate* = object
  publicKey*: string
  statusType*: StatusUpdateType
  clock*: uint64
  text*: string

proc toStatusUpdate*(jsonStatusUpdate: JsonNode): StatusUpdate =
  let statusTypeInt = jsonStatusUpdate{"statusType"}.getInt
  let statusType: StatusUpdateType = if statusTypeInt >= ord(low(StatusUpdateType)) or statusTypeInt <= ord(high(StatusUpdateType)): StatusUpdateType(statusTypeInt) else: StatusUpdateType.Unknown
  result = StatusUpdate(
    publicKey: jsonStatusUpdate{"publicKey"}.getStr,
    statusType: statusType,
    clock: uint64(jsonStatusUpdate{"clock"}.getBiggestInt),
    text: jsonStatusUpdate{"text"}.getStr
  )