import json, stint
import std/sequtils
import std/sugar
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

proc getAllCommunityTokens*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("wakuext_getAllCommunityTokens", payload)

proc addCommunityToken*(token: CommunityTokenDto): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [token.toJsonNode()]
  return core.callPrivateRPC("wakuext_addCommunityToken", payload)

proc updateCommunityTokenState*(contractAddress: string, deployState: DeployState): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [contractAddress, deployState.int]
  return core.callPrivateRPC("wakuext_updateCommunityTokenState", payload)

proc mintTo*(chainId: int, contractAddress: string, txData: JsonNode, password: string, walletAddresses: seq[string], amount: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, txData, utils.hashPassword(password), walletAddresses, amount]
  return core.callPrivateRPC("collectibles_mintTo", payload)

proc remoteBurn*(chainId: int, contractAddress: string, txData: JsonNode, password: string, tokenIds: seq[UInt256]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, txData, utils.hashPassword(password), tokenIds.map(x => x.toString(10))]
  return core.callPrivateRPC("collectibles_remoteBurn", payload)

proc estimateRemoteBurn*(chainId: int, contractAddress: string, tokenIds: seq[UInt256]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, tokenIds.map(x => x.toString(10))]
  return core.callPrivateRPC("collectibles_estimateRemoteBurn", payload)

proc contractOwner*(chainId: int, contractAddress: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress]
  return core.callPrivateRPC("collectibles_contractOwner", payload)

proc deployCollectiblesEstimate*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[]
  return core.callPrivateRPC("collectibles_deployCollectiblesEstimate", payload)

proc addTokenOwners*(chainId: int, contractAddress: string, walletAddresses: seq[string], amount: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, walletAddresses, amount]
  return core.callPrivateRPC("collectibles_addTokenOwners", payload)
