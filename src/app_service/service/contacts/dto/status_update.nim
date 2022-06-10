import json
include ../../../common/json_utils
from ../../../common/types import StatusType
from ../../../common/conversion import intToEnum

type StatusUpdateDto* = object
  publicKey*: string
  statusType*: StatusType
  clock*: uint64
  text*: string

proc toStatusUpdateDto*(jsonObj: JsonNode): StatusUpdateDto =
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("text", result.text)

  result.statusType = StatusType.Unknown
  var statusTypeInt: int
  if (jsonObj.getProp("statusType", statusTypeInt)):
      result.statusType = intToEnum(statusTypeInt, StatusType.Unknown)
