import json
import ./eth
import ../app_service/common/utils
import ./core, ./response_type
import ../app_service/service/community_tokens/dto/community_token

proc deployCollectibles*(chainId: int, deploymentParams: JsonNode, txData: JsonNode, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, deploymentParams, txData, utils.hashPassword(password)]
  return core.callPrivateRPC("collectibles_deploy", payload)

proc getCommunityTokens*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityId]
  return core.callPrivateRPC("wakuext_getCommunityTokens", payload)

proc addCommunityToken*(token: CommunityTokenDto): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [token.toJsonNode()]
  return core.callPrivateRPC("wakuext_addCommunityToken", payload)

proc updateCommunityTokenState*(contractAddress: string, deployState: DeployState): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [contractAddress, deployState.int]
  return core.callPrivateRPC("wakuext_updateCommunityTokenState", payload)