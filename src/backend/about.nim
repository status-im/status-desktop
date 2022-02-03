import json
import ./core
import response_type

export response_type

proc getWeb3ClientVersion*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("web3_clientVersion")
