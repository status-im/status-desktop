import options, logging
import json, json_serialization
import core, response_type
import strutils

from gen import rpc
import backend/wallet

import status_go

import app_service/service/community/dto/sign_params
import app_service/common/utils

rpc(addWalletConnectSession, "wallet"):
  sessionJson: string

rpc(disconnectWalletConnectSession, "wallet"):
  topic: string

rpc(getWalletConnectActiveSessions, "wallet"):
  validAtTimestamp: int

rpc(hashMessageEIP191, "wallet"):
  message: string

rpc(safeSignTypedDataForDApps, "wallet"):
  typedJson: string
  address: string
  password: string
  chainId: int
  legacy: bool

proc isSuccessResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return rpcResponse.error.isNil

proc addSession*(sessionJson: string): bool =
  try:
    let rpcRes = addWalletConnectSession(sessionJson)
    return isSuccessResponse(rpcRes):
  except Exception as e:
    error "AddWalletConnectSession failed: ", "msg", e.msg
    return false

proc disconnectSession*(topic: string): bool =
  try:
    let rpcRes = disconnectWalletConnectSession(topic)
    return isSuccessResponse(rpcRes):
  except Exception as e:
    error "wallet_disconnectWalletConnectSession failed: ", "msg", e.msg
    return false

proc getActiveSessions*(validAtTimestamp: int): JsonNode =
  try:
    let rpcRes = getWalletConnectActiveSessions(validAtTimestamp)
    if(not isSuccessResponse(rpcRes)):
      return nil

    let jsonResultStr = rpcRes.result.getStr()
    if jsonResultStr == "null":
      return nil

    if rpcRes.result.kind != JArray:
      error "Unexpected result kind: ", rpcRes.result.kind
      return nil

    return rpcRes.result
  except Exception as e:
    error "GetWalletConnectActiveSessions failed: ", "msg", e.msg
    return nil

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
    error "GetWalletConnectDapps failed: ", "msg", e.msg
    return ""

proc signMessageUnsafe*(address: string, password: string, message: string): string =
  try:
    let signParams = SignParamsDto(address: address, password: hashPassword(password), data: "0x" & toHex(message))
    let paramsStr = $toJson(signParams)
    let rpcResRaw = status_go.signMessage(paramsStr)

    let rpcRes = Json.decode(rpcResRaw, RpcResponse[JsonNode])
    if(not rpcRes.error.isNil):
      return ""
    return rpcRes.result.getStr()
  except Exception as e:
    error "status_go.signMessage failed: ", "msg", e.msg
    return ""

proc signMessage*(address: string, password: string, message: string): string =
  try:
    let hashRes = hashMessageEIP191("0x" & toHex(message))
    if not isSuccessResponse(hashRes):
      error "wallet_hashMessageEIP191 failed: ", "msg", hashRes.error.message
      return ""

    let safeHash = hashRes.result.getStr()
    let signRes = wallet.signMessage(safeHash, address, hashPassword(password))
    if not isSuccessResponse(signRes):
      error "wallet_signMessage failed: ", "msg", signRes.error.message
      return ""

    return signRes.result.getStr()
  except Exception as e:
    error "signMessageForDApps failed: ", "msg", e.msg
    return ""

proc safeSignTypedData*(address: string, password: string, typedDataJson: string, chainId: int, legacy: bool): string =
  try:
    let rpcRes = safeSignTypedDataForDApps(typedDataJson, address, hashPassword(password), chainId, legacy)
    if not isSuccessResponse(rpcRes):
      return ""

    return rpcRes.result.getStr()
  except Exception as e:
    error (if legacy: "wallet_safeSignTypedDataForDApps" else: "wallet_signTypedDataV4") & " failed: ", "msg", e.msg
    return ""
