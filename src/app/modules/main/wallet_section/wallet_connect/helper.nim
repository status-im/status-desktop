import json, strutils

include  app_service/common/json_utils

type
  RequestMethod* {.pure.} = enum
    Unknown = "unknown"
    SendTransaction = "eth_sendTransaction"
    SignTransaction = "eth_signTransaction"
    PersonalSign = "personal_sign"
    EthSign = "eth_sign"
    SignTypedData = "eth_signTypedData"

## provided json represents a `SessionRequest`
proc getRequestMethod*(jsonObj: JsonNode): RequestMethod =
  var paramsJsonObj: JsonNode
  if jsonObj.getProp("params", paramsJsonObj):
    var requestJsonObj: JsonNode
    if paramsJsonObj.getProp("request", requestJsonObj):
      var requestMethod: string
      discard requestJsonObj.getProp("method", requestMethod)
      try:
        return parseEnum[RequestMethod](requestMethod)
      except:
        discard
  return RequestMethod.Unknown

