import json
include ../../../common/json_utils

type StatusType* {.pure.} = enum
  Offline = 0
  Online
  DoNotDisturb
  Idle
  Invisible

type StatusUpdateDto* = object
  publicKey*: string
  statusType*: StatusType
  clock*: uint64
  text*: string

proc toStatusUpdateDto*(jsonObj: JsonNode): StatusUpdateDto =
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("text", result.text)

  result.statusType = StatusType.Offline
  var statusTypeInt: int
  if (jsonObj.getProp("statusType", statusTypeInt) and
    (statusTypeInt >= ord(low(StatusType)) or statusTypeInt <= ord(high(StatusType)))):
      result.statusType = StatusType(statusTypeInt)
