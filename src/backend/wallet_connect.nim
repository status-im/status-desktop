import options, logging
import json
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
