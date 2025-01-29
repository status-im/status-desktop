import json, stint
import ./eth
import ./core, ./response_type
import ../app_service/service/community_tokens/dto/community_token
import interpret/cropped_image

from ./gen import rpc

include common

# Mirrors the transfer event from status-go, services/wallet/transfer/commands.go
const eventCommunityTokenReceived*: string = "wallet-community-token-received"

proc storeDeployedCollectibles*(addressFrom: string, addressTo: string, chainId: int, txHash: string, deploymentParams: JsonNode):
  RpcResponse[JsonNode] =
  let payload = %* [addressFrom, addressTo, chainId, txHash, deploymentParams]
  return core.callPrivateRPC("communitytokens_storeDeployedCollectibles", payload)

proc storeDeployedAssets*(addressFrom: string, addressTo: string, chainId: int, txHash: string, deploymentParams: JsonNode):
  RpcResponse[JsonNode] =
  let payload = %* [addressFrom, addressTo, chainId, txHash, deploymentParams]
  return core.callPrivateRPC("communitytokens_storeDeployedAssets", payload)

proc removeCommunityToken*(chainId: int, address: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, address]
  return core.callPrivateRPC("wakuext_removeCommunityToken", payload)

proc getCommunityTokens*(communityId: string): RpcResponse[JsonNode] =
  let payload = %* [communityId]
  return core.callPrivateRPC("wakuext_getCommunityTokens", payload)

proc getAllCommunityTokens*(): RpcResponse[JsonNode] =
  let payload = %* []
  return core.callPrivateRPC("wakuext_getAllCommunityTokens", payload)

proc saveCommunityToken*(token: CommunityTokenDto, croppedImageJson: string): RpcResponse[JsonNode] =
  let croppedImage = if len(croppedImageJson) > 0: newCroppedImage(croppedImageJson) else: nil
  let payload = %* [token.toJsonNode(), croppedImage]
  return core.callPrivateRPC("wakuext_saveCommunityToken", payload)

proc addCommunityToken*(communityId: string, chainId: int, address: string): RpcResponse[JsonNode] =
  let payload = %* [communityId, chainId, address]
  return core.callPrivateRPC("wakuext_addCommunityToken", payload)

proc updateCommunityTokenState*(chainId: int, contractAddress: string, deployState: DeployState): RpcResponse[JsonNode] =
  let payload = %* [chainId, contractAddress, deployState.int]
  return core.callPrivateRPC("wakuext_updateCommunityTokenState", payload)

proc updateCommunityTokenAddress*(chainId: int, oldContractAddress: string, newContractAddress: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, oldContractAddress, newContractAddress]
  return core.callPrivateRPC("wakuext_updateCommunityTokenAddress", payload)

proc updateCommunityTokenSupply*(chainId: int, contractAddress: string, supply: Uint256): RpcResponse[JsonNode] =
  let payload = %* [chainId, contractAddress, supply.toString(10)]
  return core.callPrivateRPC("wakuext_updateCommunityTokenSupply", payload)

proc remainingSupply*(chainId: int, contractAddress: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_remainingSupply", payload)

proc remoteDestructedAmount*(chainId: int, contractAddress: string): RpcResponse[JsonNode] =
  let payload = %*[chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_remoteDestructedAmount", payload)

proc storeDeployedOwnerToken*(addressFrom: string, chainId: int, txHash: string, ownerParams: JsonNode, masterParams: JsonNode):
  RpcResponse[JsonNode] =
  let payload = %* [addressFrom, chainId, txHash, ownerParams, masterParams]
  return core.callPrivateRPC("communitytokens_storeDeployedOwnerToken", payload)

proc createCommunityTokenDeploymentSignature*(resultOut: var JsonNode, chainId: int, addressFrom: string, signerAddress: string): string =
  try:
    let payload = %*[chainId, addressFrom, signerAddress]
    let response = core.callPrivateRPC("wakuext_createCommunityTokenDeploymentSignature", payload)
    return prepareResponse(resultOut, response)
  except Exception as e:
    return e.msg

proc registerOwnerTokenReceivedNotification*(communityId: string): RpcResponse[JsonNode] =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerOwnerTokenReceivedNotification", payload)

proc registerReceivedOwnershipNotification*(communityId: string): RpcResponse[JsonNode] =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerReceivedOwnershipNotification", payload)

proc registerSetSignerFailedNotification*(communityId: string): RpcResponse[JsonNode] =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerSetSignerFailedNotification", payload)

proc registerSetSignerDeclinedNotification*(communityId: string): RpcResponse[JsonNode] =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerSetSignerDeclinedNotification", payload)

proc registerLostOwnershipNotification*(communityId: string): RpcResponse[JsonNode] =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerLostOwnershipNotification", payload)

proc getOwnerTokenOwnerAddress*(chainId: int, contractAddress: string): RpcResponse[JsonNode] =
  let payload = %*[chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_ownerTokenOwnerAddress", payload)

proc reTrackOwnerTokenDeploymentTransaction*(chainId: int, contractAddress: string): RpcResponse[JsonNode] =
  let payload = %*[chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_reTrackOwnerTokenDeploymentTransaction", payload)

rpc(registerReceivedCommunityTokenNotification, "wakuext"):
  communityId: string
  isFirst: bool
  toTokenData: string
