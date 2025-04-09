import options, chronicles
import json, app_service/common/safe_json_serialization
import core, response_type

from gen import rpc

rpc(addWalletConnectSession, "wallet"):
  sessionJson: string

rpc(disconnectWalletConnectSession, "wallet"):
  topic: string

rpc(getWalletConnectActiveSessions, "wallet"):
  validAtTimestamp: int64

rpc(hashMessageEIP191, "wallet"):
  message: string

proc isSuccessResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return rpcResponse.error.isNil

proc addSession*(sessionJson: string): bool =
  try:
    let rpcRes = addWalletConnectSession(sessionJson)
    return isSuccessResponse(rpcRes)
  except Exception as e:
    error "AddWalletConnectSession failed: ", msg = e.msg
    return false

proc disconnectSession*(topic: string): bool =
  try:
    let rpcRes = disconnectWalletConnectSession(topic)
    return isSuccessResponse(rpcRes)
  except Exception as e:
    error "wallet_disconnectWalletConnectSession failed: ", msg = e.msg
    return false

# returns nil if error
proc getActiveSessions*(validAtTimestamp: int64): JsonNode =
  try:
    let rpcRes = getWalletConnectActiveSessions(validAtTimestamp)

    if(not isSuccessResponse(rpcRes)):
      return nil

    let jsonResultStr = $rpcRes.result
    if jsonResultStr == "null" or jsonResultStr == "":
      return newJArray()

    if rpcRes.result.kind != JArray:
      error "Unexpected result kind: ", kind = rpcRes.result.kind
      return nil

    return rpcRes.result
  except Exception as e:
    error "GetWalletConnectActiveSessions failed: ", msg = e.msg
    return nil

proc getDapps*(validAtEpoch: int64, testChains: bool): string =
  try:
    let params = %*[validAtEpoch, testChains]
    let rpcResRaw = callPrivateRPCNoDecode("wallet_getWalletConnectDapps", params)
    let rpcRes = Json.safeDecode(rpcResRaw, RpcResponse[JsonNode])
    if(not rpcRes.error.isNil):
      return ""

    # Expect nil golang array to be valid empty array
    let jsonArray = $rpcRes.result
    return if jsonArray != "null": jsonArray else: "[]"
  except Exception as e:
    error "GetWalletConnectDapps failed: ", msg = e.msg
    return ""