import json, strutils, json_serialization, chronicles
import core, utils
import response_type

import status_go

export response_type

logScope:
  topics = "rpc-general"

proc validateMnemonic*(mnemonic: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  try:
    let response = status_go.validateMnemonic(mnemonic.strip())
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "validateMnemonic", exception=e.msg
    raise newException(RpcException, e.msg)

proc startMessenger*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("startMessenger".prefix, payload)

proc generateSymKeyFromPassword*(password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [password]
  result = core.callPrivateRPC("waku_generateSymKeyFromPassword", payload)

proc adminPeers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("admin_peers", payload)

proc wakuV2Peers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("peers".prefix, payload)

proc dialPeer*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address]
  result = core.callPrivateRPC("dialPeer".prefix, payload)

proc dropPeerByID*(peer: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [peer]
  result = core.callPrivateRPC("dropPeer".prefix, payload)

proc removePeer*(peer: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [peer]
  result = core.callPrivateRPC("admin_removePeer", payload)
