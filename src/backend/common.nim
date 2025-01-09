import json
import response_type

const NO_RESULT* = "no result"

proc isErrorResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  if not rpcResponse.error.isNil:
    return true
  return false

proc prepareResponse(
    resultOut: var JsonNode, rpcResponse: RpcResponse[JsonNode]
): string =
  if isErrorResponse(rpcResponse):
    return rpcResponse.error.message
  if rpcResponse.result.isNil:
    return NO_RESULT
  resultOut = rpcResponse.result
