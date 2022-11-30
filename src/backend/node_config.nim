import json, json_serialization, chronicles
import ./core
import ./response_type
import utils

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

proc switchFleet*(fleet: string, nodeConfig: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    info "switching fleet", fleet
    let response = status_go.switchFleet(fleet, $nodeConfig)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "switchFleet", exception=e.msg
    raise newException(RpcException, e.msg)

proc enableCommunityHistoryArchiveSupport*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    result = core.callPrivateRPC("enableCommunityHistoryArchiveProtocol".prefix)
  except RpcException as e:
    error "error doing rpc request", methodName = "enableCommunityHistoryArchiveProtocol", exception=e.msg
    raise newException(RpcException, e.msg)