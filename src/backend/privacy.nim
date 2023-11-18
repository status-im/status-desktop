import json, json_serialization, chronicles
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-privacy"

proc changeDatabasePassword*(keyUID: string, oldHashedPassword: string, newHashedPassword: string): RpcResponse[JsonNode]
  {.raises: [Exception].} =
  try:
    let response = status_go.changeDatabasePassword(keyUID, oldHashedPassword, newHashedPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "changeDatabasePassword", exception=e.msg
    raise newException(RpcException, e.msg)
