import json
import ./eth

# Retrieves number of sticker packs owned by user
# See https://notes.status.im/Q-sQmQbpTOOWCQcYiXtf5g#Read-Sticker-Packs-owned-by-a-user
# for more details
proc getBalance*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)

  if not response.error.isNil:
    raise newException(RpcException, "Error getting stickers balance: " & response.error.message)

  return response

proc tokenOfOwnerByIndex*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting owned tokens: " & response.error.message)

  return response

proc getPackIdFromTokenId*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting pack id from token id: " & response.error.message)

  return response

proc getPackCount*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)

  if not response.error.isNil:
    raise newException(RpcException, "Error getting stickers balance: " & response.error.message)

  return response
