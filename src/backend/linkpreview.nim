import json
import core
import response_type

export response_type

proc prefix*(methodName: string): string =
  result = "linkpreview_" & methodName

proc getTextURLsToUnfurl*(text: string): RpcResponse[JsonNode] =
  let payload = %*[text]
  result = callPrivateRPC("getTextURLsToUnfurl".prefix, payload)

proc unfurlUrls*(urls: seq[string]): RpcResponse[JsonNode] =
  let payload = %*[urls]
  result = callPrivateRPC("unfurlURLs".prefix, payload)
