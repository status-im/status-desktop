import json, json_serialization, chronicles
import core, ../app_service/common/utils
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-privacy"

proc changeDatabaseHashedPassword*(keyUID: string, oldHashedPassword: string, newHashedPassword: string): RpcResponse[JsonNode]
  {.raises: [Exception].} =
  try:
    let response = status_go.changeDatabasePassword(keyUID, oldHashedPassword, newHashedPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "changeDatabasePassword", exception=e.msg
    raise newException(RpcException, e.msg)

proc changeDatabasePassword*(keyUID: string, password: string, newPassword: string): RpcResponse[JsonNode]
  {.raises: [Exception].} =
    let hashedPassword = hashPassword(password)
    let hashedNewPassword = hashPassword(newPassword)
    return changeDatabaseHashedPassword(keyUID, hashedPassword, hashedNewPassword)

proc getLinkPreviewWhitelist*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("getLinkPreviewWhitelist".prefix, payload)
