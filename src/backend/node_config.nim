import json, json_serialization, chronicles
import ./core
import ./response_type
import ../app_service/common/utils

import status_go

export response_type

logScope:
  topics = "rpc-node-config"

proc getNodeConfig*(): RpcResponse[JsonNode] =
  try:
    let response = status_go.getNodeConfig()
    result.result = response.parseJSON()

  except RpcException as e:
    error "error doing rpc request", methodName = "getNodeConfig", exception=e.msg
    raise newException(RpcException, e.msg)

proc switchFleet*(fleet: string, nodeConfig: JsonNode): RpcResponse[JsonNode] =
  try:
    info "switching fleet", fleet
    let response = status_go.switchFleet(fleet, $nodeConfig)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "switchFleet", exception=e.msg
    raise newException(RpcException, e.msg)

proc enableCommunityHistoryArchiveSupport*(): RpcResponse[JsonNode] =
  try:
    result = core.callPrivateRPC("enableCommunityHistoryArchiveProtocol".prefix)
  except RpcException as e:
    error "error doing rpc request", methodName = "enableCommunityHistoryArchiveProtocol", exception=e.msg
    raise newException(RpcException, e.msg)

proc disableCommunityHistoryArchiveSupport*(): RpcResponse[JsonNode] =
  try:
    result = core.callPrivateRPC("disableCommunityHistoryArchiveProtocol".prefix)
  except RpcException as e:
    error "error doing rpc request", methodName = "disableCommunityHistoryArchiveProtocol", exception=e.msg
    raise newException(RpcException, e.msg)

proc  setLogLevel*(logLevel: LogLevel): RpcResponse[JsonNode] =
  try:
    let payload = %*[{
      "logLevel": $logLevel
    }]
    result = core.callPrivateRPC("setLogLevel".prefix, payload)
  except RpcException as e:
    error "error doing rpc request", methodName = "setLogLevel", exception=e.msg
    raise newException(RpcException, e.msg)
