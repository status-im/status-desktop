import json, app_service/common/safe_json_serialization
import response_type

import status_go

export response_type

proc emojiHashOf*(pubkey: string): RpcResponse[JsonNode] =
    result = Json.safeDecode(status_go.emojiHash(pubkey), RpcResponse[JsonNode])

proc colorHashOf*(pubkey: string): RpcResponse[JsonNode] =
    result = Json.safeDecode(status_go.colorHash(pubkey), RpcResponse[JsonNode])

proc colorIdOf*(pubkey: string): RpcResponse[JsonNode] =
    result = Json.safeDecode(status_go.colorID(pubkey), RpcResponse[JsonNode])
