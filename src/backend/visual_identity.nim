import json, json_serialization
import response_type

import status_go

export response_type

proc emojiHashOf*(pubkey: string): RpcResponse[JsonNode] =
    result = Json.decode(status_go.emojiHash(pubkey), RpcResponse[JsonNode])

proc colorIdOf*(pubkey: string): RpcResponse[JsonNode] =
    result = Json.decode(status_go.colorID(pubkey), RpcResponse[JsonNode])
