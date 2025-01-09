import json
import core, ../app_service/common/utils
import response_type

export response_type

proc adminPeers*(): RpcResponse[JsonNode] =
  let payload = %*[]
  result = callPrivateRPC("admin_peers", payload)

proc wakuV2Peers*(): RpcResponse[JsonNode] =
  let payload = %*[]
  result = callPrivateRPC("peers".prefix, payload)

proc sendRPCMessageRaw*(inputJSON: string): string =
  result = callPrivateRPCRaw(inputJSON)

proc getRpcStats*(): string =
  result = callPrivateRPCNoDecode("rpcstats_getStats")

proc resetRpcStats*() =
  discard callPrivateRPCNoDecode("rpcstats_reset")
