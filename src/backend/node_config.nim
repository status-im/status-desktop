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
  return core.callPrivateRPC("enableCommunityHistoryArchiveProtocol".prefix, %* [])

proc disableCommunityHistoryArchiveSupport*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("disableCommunityHistoryArchiveProtocol".prefix, %* [])

proc setLogLevel*(logLevel: LogLevel): RpcResponse[JsonNode] =
  let payload = %*[{
    "logLevel": $logLevel
  }]
  result = core.callPrivateRPC("setLogLevel".prefix, payload)

proc setMaxLogBackups*(maxLogBackups: int): RpcResponse[JsonNode] =
  let payload = %*[{
    "maxLogBackups": maxLogBackups
  }]
  return core.callPrivateRPC("setMaxLogBackups".prefix, payload)

proc setLightClient*(enabled: bool): RpcResponse[JsonNode] =
  let payload = %*[{
    "enabled": enabled
  }]
  return core.callPrivateRPC("setLightClient".prefix, payload)

proc saveNewWakuNode*(nodeAddress: string): RpcResponse[JsonNode] =
  let payload = %*[{
    "nodeAddress": nodeAddress
  }]
  return core.callPrivateRPC("saveNewWakuNode".prefix, payload)
