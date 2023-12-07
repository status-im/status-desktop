import json
import core, ../app_service/common/utils
import response_type

export response_type

proc adminPeers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
    let payload = %* []
    result = callPrivateRPC("admin_peers", payload)

proc wakuV2Peers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
    let payload = %* []
    result = callPrivateRPC("peers".prefix, payload)

proc sendRPCMessageRaw*(inputJSON: string): string {.raises: [Exception].} =
    result = callPrivateRPCRaw(inputJSON)
