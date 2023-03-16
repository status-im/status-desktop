import json, json_serialization, chronicles
import core, ../app_service/common/utils
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-privacy"

proc changeDatabasePassword*(keyUID: string, password: string, newPassword: string): RpcResponse[JsonNode]
  {.raises: [Exception].} =
  try:
    let hashedPassword = hashPassword(password)
    let hashedNewPassword = hashPassword(newPassword)
    let response = status_go.changeDatabasePassword(keyUID, hashedPassword, hashedNewPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "changeDatabasePassword", exception=e.msg
    raise newException(RpcException, e.msg)

proc lowerDatabasePassword*(keyUID: string, password: string): RpcResponse[JsonNode]
  {.raises: [Exception].} =
  try:
    let hashedPassword = hashPassword(password, lower=false)
    let hashedNewPassword = hashPassword(password)
    let response = status_go.changeDatabasePassword(keyUID, hashedPassword, hashedNewPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "lowerDatabasePassword", exception=e.msg
    raise newException(RpcException, e.msg)


proc getLinkPreviewWhitelist*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("getLinkPreviewWhitelist".prefix, payload)