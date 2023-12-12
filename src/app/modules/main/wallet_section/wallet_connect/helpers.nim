import json, strutils
import uri

include  app_service/common/json_utils

type
  RequestMethod* {.pure.} = enum
    Unknown = "unknown"
    SendTransaction = "eth_sendTransaction"
    SignTransaction = "eth_signTransaction"
    PersonalSign = "personal_sign"
    EthSign = "eth_sign"
    SignTypedData = "eth_signTypedData"
    SignTypedDataV3 = "eth_signTypedData_v3"
    SignTypedDataV4 = "eth_signTypedData_v4"

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

# check and extract Wallet Connect URI parameter from a deep link updated URL
proc extractAndCheckUriParameter*(url: string): (bool, string) =
  let parsedUrl = parseUri(url)

  if parsedUrl.path != "/wc":
    return (false, "")

  for (key, value) in decodeQuery(parsedUrl.query):
    if key.toLower == "uri":
      if value.startsWith("wc:"):
        return (true, value)

  return (false, "")
