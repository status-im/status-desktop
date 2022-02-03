import json
import core, utils
import response_type

export response_type

proc adminPeers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
    let payload = %* []
    result = callPrivateRPC("admin_peers", payload)

proc wakuV2Peers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
    let payload = %* []
    result = callPrivateRPC("peers", payload)

proc sendRPCMessageRaw*(inputJSON: string): string {.raises: [Exception].} =
    result = callPrivateRPCRaw(inputJSON)

proc getBloomFilter*(): RpcResponse[JsonNode] {.raises: [Exception].} =
    let payload = %* []
    result = callPrivateRPC("bloomFilter".prefix, payload)