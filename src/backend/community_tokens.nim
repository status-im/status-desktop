import json
import ./eth
import ./utils
import ./core, ./response_type

proc deployCollectibles*(chainId: int, deploymentParams: JsonNode, txData: JsonNode, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, deploymentParams, txData, utils.hashPassword(password)]
  return core.callPrivateRPC("collectibles_deploy", payload)
