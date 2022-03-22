import json, json_serialization, chronicles
import core, utils
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

proc getLinkPreviewWhitelist*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("getLinkPreviewWhitelist".prefix, payload)