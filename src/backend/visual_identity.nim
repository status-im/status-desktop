import json, json_serialization
import response_type

import status_go

export response_type

proc emojiHashOf*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
    result = Json.decode(status_go.emojiHash(pubkey), RpcResponse[JsonNode])

proc colorHashOf*(pubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
    result = Json.decode(status_go.colorHash(pubkey), RpcResponse[JsonNode])
