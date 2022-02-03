import json, json_serialization, chronicles
import ./core
import ./response_type

import status_go

export response_type

logScope:
  topics = "rpc-node-config"

proc getNodeConfig*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.getNodeConfig()
    result.result = response.parseJSON()

  except RpcException as e:
    error "error doing rpc request", methodName = "getNodeConfig", exception=e.msg
    raise newException(RpcException, e.msg)