import json, strutils, json_serialization, chronicles
import core, ../app_service/common/utils
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-general"

proc validateMnemonic*(mnemonic: string): RpcResponse[JsonNode] =
  try:
    let response = status_go.validateMnemonic(mnemonic.strip())
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "validateMnemonic", exception=e.msg
    raise newException(RpcException, e.msg)

proc startMessenger*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = core.callPrivateRPC("startMessenger".prefix, payload)

proc logout*(): RpcResponse[JsonNode] =
  try:
    let response = status_go.logout()
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error logging out", methodName = "logout", exception=e.msg
    raise newException(RpcException, e.msg)

proc generateSymKeyFromPassword*(password: string): RpcResponse[JsonNode] =
  let payload = %* [password]
  result = core.callPrivateRPC("waku_generateSymKeyFromPassword", payload)

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
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "getPasswordStrengthScore", exception=e.msg
    raise newException(RpcException, e.msg)

proc generateImages*(imagePath: string, aX, aY, bX, bY: int): RpcResponse[JsonNode] =
  try:
    let response = status_go.generateImages(imagePath, aX, aY, bX, bY)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "generateImages", exception=e.msg
    raise newException(RpcException, e.msg)

proc initKeystore*(keystoreDir: string): RpcResponse[JsonNode] =
  try:
    let response = status_go.initKeystore(keystoreDir)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error", methodName = "initKeystore", exception=e.msg
    raise newException(RpcException, e.msg)

type
  Node = ref object
    value: int

proc backupData*(): RpcResponse[JsonNode] =
  echo "<<< ABOUT TO CRASH"

  # FIXME: Force a crash to test the crash reporting

  var n: Node = nil
  echo n.value

  let p = cast[ptr int](0x1)  # Point to an invalid address
  echo p[]  # Attempt to access it

  # var arr = cast[ptr array[1, int]](nil)  # Array pointer with no valid memory
  # echo arr[1]  # Out-of-bounds access

  let payload = %* []
  result = callPrivateRPC("backupData".prefix, payload)

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
