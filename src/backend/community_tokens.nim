import json, stint
import std/sequtils
import std/sugar
import ./eth
import ./core, ./response_type
import ../app_service/service/community_tokens/dto/community_token
import interpret/cropped_image

proc deployCollectibles*(chainId: int, deploymentParams: JsonNode, txData: JsonNode, hashedPassword: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, deploymentParams, txData, hashedPassword]
  return core.callPrivateRPC("communitytokens_deployCollectibles", payload)

proc deployAssets*(chainId: int, deploymentParams: JsonNode, txData: JsonNode, hashedPassword: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, deploymentParams, txData, hashedPassword]
  return core.callPrivateRPC("communitytokens_deployAssets", payload)

proc removeCommunityToken*(chainId: int, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, address]
  return core.callPrivateRPC("wakuext_removeCommunityToken", payload)

proc getCommunityTokens*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityId]
  return core.callPrivateRPC("wakuext_getCommunityTokens", payload)

proc getAllCommunityTokens*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("wakuext_getAllCommunityTokens", payload)

proc saveCommunityToken*(token: CommunityTokenDto, croppedImageJson: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let croppedImage = if len(croppedImageJson) > 0: newCroppedImage(croppedImageJson) else: nil
  let payload = %* [token.toJsonNode(), croppedImage]
  return core.callPrivateRPC("wakuext_saveCommunityToken", payload)

proc addCommunityToken*(communityId: string, chainId: int, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityId, chainId, address]
  return core.callPrivateRPC("wakuext_addCommunityToken", payload)

proc updateCommunityTokenState*(chainId: int, contractAddress: string, deployState: DeployState): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, deployState.int]
  return core.callPrivateRPC("wakuext_updateCommunityTokenState", payload)

proc updateCommunityTokenAddress*(chainId: int, oldContractAddress: string, newContractAddress: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, oldContractAddress, newContractAddress]
  return core.callPrivateRPC("wakuext_updateCommunityTokenAddress", payload)

proc updateCommunityTokenSupply*(chainId: int, contractAddress: string, supply: Uint256): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, supply.toString(10)]
  return core.callPrivateRPC("wakuext_updateCommunityTokenSupply", payload)

proc mintTokens*(chainId: int, contractAddress: string, txData: JsonNode, hashedPasword: string, walletAddresses: seq[string], amount: Uint256): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, txData, hashedPasword, walletAddresses, amount.toString(10)]
  return core.callPrivateRPC("communitytokens_mintTokens", payload)

proc estimateMintTokens*(chainId: int, contractAddress: string, fromAddress: string, walletAddresses: seq[string], amount: Uint256): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, fromAddress, walletAddresses, amount.toString(10)]
  return core.callPrivateRPC("communitytokens_estimateMintTokens", payload)

proc remoteBurn*(chainId: int, contractAddress: string, txData: JsonNode, hashedPassword: string, tokenIds: seq[UInt256]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, txData, hashedPassword, tokenIds.map(x => x.toString(10))]
  return core.callPrivateRPC("communitytokens_remoteBurn", payload)

proc estimateRemoteBurn*(chainId: int, contractAddress: string, fromAddress: string, tokenIds: seq[UInt256]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, fromAddress, tokenIds.map(x => x.toString(10))]
  return core.callPrivateRPC("communitytokens_estimateRemoteBurn", payload)

proc burn*(chainId: int, contractAddress: string, txData: JsonNode, hashedPassword: string, amount: Uint256): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, txData, hashedPassword, amount.toString(10)]
  return core.callPrivateRPC("communitytokens_burn", payload)

proc estimateBurn*(chainId: int, contractAddress: string, fromAddress: string, amount: Uint256): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, fromAddress, amount.toString(10)]
  return core.callPrivateRPC("communitytokens_estimateBurn", payload)

proc estimateSetSignerPubKey*(chainId: int, contractAddress: string, fromAddress: string, newSignerPubkey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, fromAddress, newSignerPubkey]
  return core.callPrivateRPC("communitytokens_estimateSetSignerPubKey", payload)

proc remainingSupply*(chainId: int, contractAddress: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_remainingSupply", payload)

proc deployCollectiblesEstimate*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[]
  return core.callPrivateRPC("communitytokens_deployCollectiblesEstimate", payload)

proc deployAssetsEstimate*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[]
  return core.callPrivateRPC("communitytokens_deployAssetsEstimate", payload)

proc remoteDestructedAmount*(chainId: int, contractAddress: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_remoteDestructedAmount", payload)

proc deployOwnerTokenEstimate*(chainId: int, addressFrom: string, ownerParams: JsonNode, masterParams: JsonNode, signature: string, communityId: string, signerPubKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, addressFrom, ownerParams, masterParams, signature, communityId, signerPubKey]
  return core.callPrivateRPC("communitytokens_deployOwnerTokenEstimate", payload)

proc deployOwnerToken*(chainId: int, ownerParams: JsonNode, masterParams: JsonNode, signature: string, communityId: string, signerPubKey: string, txData: JsonNode, hashedPassword: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, ownerParams, masterParams, signature, communityId, signerPubKey, txData, hashedPassword]
  return core.callPrivateRPC("communitytokens_deployOwnerToken", payload)

proc getMasterTokenContractAddressFromHash*(chainId: int, transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, transactionHash]
  return core.callPrivateRPC("communitytokens_getMasterTokenContractAddressFromHash", payload)

proc getOwnerTokenContractAddressFromHash*(chainId: int, transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, transactionHash]
  return core.callPrivateRPC("communitytokens_getOwnerTokenContractAddressFromHash", payload)

proc createCommunityTokenDeploymentSignature*(chainId: int, addressFrom: string, signerAddress: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, addressFrom, signerAddress]
  return core.callPrivateRPC("wakuext_createCommunityTokenDeploymentSignature", payload)

proc setSignerPubKey*(chainId: int, contractAddress: string, txData: JsonNode, newSignerPubKey: string, hashedPassword: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, contractAddress, txData, hashedPassword, newSignerPubKey]
  return core.callPrivateRPC("communitytokens_setSignerPubKey", payload)

proc registerOwnerTokenReceivedNotification*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerOwnerTokenReceivedNotification", payload)

proc registerReceivedOwnershipNotification*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerReceivedOwnershipNotification", payload)

proc registerSetSignerFailedNotification*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerSetSignerFailedNotification", payload)

proc registerSetSignerDeclinedNotification*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerSetSignerDeclinedNotification", payload)

proc registerLostOwnershipNotification*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_registerLostOwnershipNotification", payload)

proc promoteSelfToControlNode*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[communityId]
  return core.callPrivateRPC("wakuext_promoteSelfToControlNode", payload)

proc getOwnerTokenOwnerAddress*(chainId: int, contractAddress: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chainId, contractAddress]
  return core.callPrivateRPC("communitytokens_ownerTokenOwnerAddress", payload)
