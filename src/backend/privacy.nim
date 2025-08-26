import json, json_serialization, chronicles
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-privacy"

proc changeDatabasePassword*(keyUID: string, oldHashedPassword: string, newHashedPassword: string): RpcResponse[JsonNode]
  =
  try:
    let request = %* {
      "keyUID": keyUID,
      "oldPassword": oldHashedPassword,
      "newPassword": newHashedPassword,
    }
    let response = status_go.changeDatabasePasswordV2($request)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "changeDatabasePassword", exception=e.msg
    raise newException(RpcException, e.msg)
