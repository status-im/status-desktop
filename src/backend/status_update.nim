import json
import ./core, ./response_type

export response_type

proc setUserStatus*(newStatus: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [newStatus, ""]
  result = core.callPrivateRPC("wakuext_setUserStatus", payload)
