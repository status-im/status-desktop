import json, strutils, app_service/common/safe_json_serialization, chronicles
import core, ../app_service/common/utils
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-general"

proc validateMnemonic*(mnemonic: string): RpcResponse[JsonNode] =
  try:
    let response = status_go.validateMnemonic(mnemonic.strip())
    result.result = Json.safeDecode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "validateMnemonic", exception=e.msg
    raise newException(RpcException, e.msg)

proc startMessenger*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = core.callPrivateRPC("startMessenger".prefix, payload)

proc logout*(): RpcResponse[JsonNode] =
  try:
    let response = status_go.logout()
    result.result = Json.safeDecode(response, JsonNode)
  except RpcException as e:
    error "error logging out", methodName = "logout", exception=e.msg
    raise newException(RpcException, e.msg)

proc adminPeers*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = core.callPrivateRPC("admin_peers", payload)

proc wakuV2Peers*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = core.callPrivateRPC("peers".prefix, payload)

proc dialPeer*(address: string): RpcResponse[JsonNode] =
  let payload = %* [address]
  result = core.callPrivateRPC("dialPeer".prefix, payload)

proc dropPeerByID*(peer: string): RpcResponse[JsonNode] =
  let payload = %* [peer]
  result = core.callPrivateRPC("dropPeer".prefix, payload)

proc removePeer*(peer: string): RpcResponse[JsonNode] =
  let payload = %* [peer]
  result = core.callPrivateRPC("admin_removePeer", payload)

proc getPasswordStrengthScore*(password: string, userInputs: seq[string]): RpcResponse[JsonNode] =
  let params = %* {"password": password, "userInputs": userInputs}
  try:
    let response = status_go.getPasswordStrengthScore($(params))
    result.result = Json.safeDecode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "getPasswordStrengthScore", exception=e.msg
    raise newException(RpcException, e.msg)

proc generateImages*(imagePath: string, aX, aY, bX, bY: int): RpcResponse[JsonNode] =
  try:
    let response = status_go.generateImages(imagePath, aX, aY, bX, bY)
    result.result = Json.safeDecode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "generateImages", exception=e.msg
    raise newException(RpcException, e.msg)

proc initKeystore*(keystoreDir: string): RpcResponse[JsonNode] =
  try:
    let response = status_go.initKeystore(keystoreDir)
    result.result = Json.safeDecode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "initKeystore", exception=e.msg
    raise newException(RpcException, e.msg)

proc backupData*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = callPrivateRPC("backupData".prefix, payload)

proc importLocalBackupFile*(filePath: string): RpcResponse[JsonNode] =
  let payload = %* [filePath]
  result = callPrivateRPC("importLocalBackupFile".prefix, payload)

proc parseSharedUrl*(url: string): RpcResponse[JsonNode] =
  result = callPrivateRPC("parseSharedURL".prefix, %*[url])

proc hashMessageForSigning*(message: string): string =
  try: 
    let response = status_go.hashMessage(message)
    let jsonResponse = parseJson(response)
    return jsonResponse{"result"}.getStr()
  except Exception as e:
    error "hashMessage: failed to parse json response", error = e.msg
    return ""
