import options, logging
import json, json_serialization
import core, response_type
import strutils

from gen import rpc
import backend

import status_go

import app_service/service/community/dto/sign_params

import app_service/common/utils

rpc(addWalletConnectSession, "wallet"):
  sessionJson: string

rpc(signTypedDataV4, "wallet"):
  typedJson: string
  address: string
  password: string

proc isSuccessResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return rpcResponse.error.isNil

proc addSession*(sessionJson: string): bool =
  try:
    let rpcRes = addWalletConnectSession(sessionJson)
    return isSuccessResponse(rpcRes):
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

proc signMessage*(address: string, password: string, message: string): string =
  try:
    let signParams = SignParamsDto(address: address, password: hashPassword(password), data: "0x" & toHex(message))
    let paramsStr = $toJson(signParams)
    let rpcResRaw = status_go.signMessage(paramsStr)

    let rpcRes = Json.decode(rpcResRaw, RpcResponse[JsonNode])
    if(not rpcRes.error.isNil):
     return ""
    return rpcRes.result.getStr()
  except Exception as e:
    warn "status_go.signMessage failed: ", "msg", e.msg
    return ""

proc signTypedData*(address: string, password: string, typedDataJson: string): string =
  try:
    let rpcRes = signTypedDataV4(typedDataJson, address, hashPassword(password))

    if not isSuccessResponse(rpcRes):
      return ""

    return rpcRes.result.getStr()
  except Exception as e:
    warn "wallet_signTypedDataV4 failed: ", "msg", e.msg
    return ""
