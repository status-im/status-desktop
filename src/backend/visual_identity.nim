import json, chronicles, core
import response_type

export response_type

logScope:
  topics = "rpc-visual-identity"

proc emojiHashOf*(key: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [key]
  result = core.callPrivateRPC("visualIdentity_emojiHashOf", payload)

proc colorHashOf*(key: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [key]
  result = core.callPrivateRPC("visualIdentity_colorHashOf", payload)
