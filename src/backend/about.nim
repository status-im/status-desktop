import json
import ./core
import response_type

export response_type

proc checkForUpdates*(chainId: int, ensAddress: string, currVersion: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, ensAddress, currVersion]
  result = callPrivateRPC("updates_check", payload)
