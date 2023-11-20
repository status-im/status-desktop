import json

include  app_service/common/json_utils

type
  SessionResponseDto* = ref object
    keyUid*: string
    address*: string
    addressPath*: string
    signOnKeycard*: bool
    messageToSign*: string
    signedMessage*: string

proc toSessionResponseDto*(jsonObj: JsonNode): SessionResponseDto =
  result = SessionResponseDto()
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("addressPath", result.addressPath)
  discard jsonObj.getProp("signOnKeycard", result.signOnKeycard)
  discard jsonObj.getProp("messageToSign", result.messageToSign)
  discard jsonObj.getProp("signedMessage", result.signedMessage)