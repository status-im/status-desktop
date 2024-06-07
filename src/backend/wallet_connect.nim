import options, logging
import json, json_serialization
import core, response_type

from gen import rpc
import backend

rpc(addWalletConnectSession, "wallet"):
  sessionJson: string

proc isErrorResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return not rpcResponse.error.isNil

proc addSession*(sessionJson: string): bool =
  try:
    let rpcRes = addWalletConnectSession(sessionJson)
    return isErrorResponse(rpcRes):
  except Exception as e:
    warn "AddWalletConnectSession failed: ", "msg", e.msg
    return false

proc getDapps*(validAtEpoch: int64, testChains: bool): string =
  try:
    let params = %*[validAtEpoch, testChains]
    let rpcResRaw = callPrivateRPCNoDecode("wallet_getWalletConnectDapps", params)
    let rpcRes = Json.decode(rpcResRaw, RpcResponse[JsonNode])
    if(not rpcRes.error.isNil):
      return ""

    # Expect nil golang array to be valid empty array
    let jsonArray = $rpcRes.result
    return if jsonArray != "null": jsonArray else: "[]"
  except Exception as e:
    warn "GetWalletConnectDapps failed: ", "msg", e.msg
    return ""
