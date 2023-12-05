import json, strutils
import core, ../app_service/common/utils
import response_type

import interpret/cropped_image

export response_type

proc getCommunityTags*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("communityTags".prefix)

proc muteCategory*(communityId: string, categoryId: string, interval: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("muteCommunityCategory".prefix, %* [
    {
      "communityId": communityId,
      "categoryId": categoryId,
      "mutedType": interval,
    }
  ])

proc unmuteCategory*(communityId: string, categoryId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("unmuteCommunityCategory".prefix, %* [communityId, categoryId])

proc getCuratedCommunities*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("curatedCommunities".prefix, payload)

proc getAllCommunities*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("communities".prefix)

proc spectateCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("spectateCommunity".prefix, %*[communityId])

proc generateJoiningCommunityRequestsForSigning*(
    memberPubKey: string,
    communityId: string,
    addressesToReveal: seq[string]
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[memberPubKey, communityId, addressesToReveal]
  result = callPrivateRPC("generateJoiningCommunityRequestsForSigning".prefix, payload)

proc generateEditCommunityRequestsForSigning*(
    memberPubKey: string,
    communityId: string,
    addressesToReveal: seq[string]
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[memberPubKey, communityId, addressesToReveal]
  result = callPrivateRPC("generateEditCommunityRequestsForSigning".prefix, payload)

## `signParams` represents a json array of SignParamsDto.
proc signData*(signParams: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  if signParams.kind != JArray:
    raise newException(Exception, "signParams must be an array")
  let payload = %*[signParams]
  result = callPrivateRPC("signData".prefix, payload)

proc requestToJoinCommunity*(
    communityId: string,
    ensName: string,
    addressesToShare: seq[string],
    signatures: seq[string],
    airdropAddress: string,
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestToJoinCommunity".prefix, %*[{
    "communityId": communityId,
    "ensName": ensName,
    "addressesToReveal": addressesToShare,
    "signatures": signatures,
    "airdropAddress": airdropAddress,
  }])

proc editSharedAddresses*(
    communityId: string,
    addressesToShare: seq[string],
    signatures: seq[string],
    airdropAddress: string,
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("editSharedAddressesForCommunity".prefix, %*[{
    "communityId": communityId,
    "addressesToReveal": addressesToShare,
    "signatures": signatures,
    "airdropAddress": airdropAddress,
  }])

proc getRevealedAccountsForMember*(
    communityId: string,
    memberPubkey: string,
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("getRevealedAccounts".prefix, %*[communityId, memberPubkey])

proc getRevealedAccountsForAllMembers*(
    communityId: string,
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("getRevealedAccountsForAllMembers".prefix, %*[communityId])

proc checkPermissionsToJoinCommunity*(communityId: string, addresses: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("checkPermissionsToJoinCommunity".prefix, %*[{
    "communityId": communityId,
    "addresses": addresses
  }])

proc reevaluateCommunityMembersPermissions*(
    communityId: string,
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("reevaluateCommunityMembersPermissions".prefix, %*[{
    "communityId": communityId
  }])

proc checkCommunityChannelPermissions*(communityId: string, chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("checkCommunityChannelPermissions".prefix, %*[{
    "communityId": communityId,
    "chatId": chatId
  }])

proc checkAllCommunityChannelsPermissions*(communityId: string, addresses: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("checkAllCommunityChannelsPermissions".prefix, %*[{
    "communityId": communityId,
    "addresses": addresses,
  }])

proc allNonApprovedCommunitiesRequestsToJoin*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("allNonApprovedCommunitiesRequestsToJoin".prefix)

proc cancelRequestToJoinCommunity*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("cancelRequestToJoinCommunity".prefix, %*[{
    "id": requestId
  }])

proc leaveCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("leaveCommunity".prefix, %*[communityId])

proc createCommunity*(
    name: string,
    description: string,
    introMessage: string,
    outroMessage: string,
    access: int,
    color: string,
    tags: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int,
    historyArchiveSupportEnabled: bool,
    pinMessageAllMembersEnabled: bool,
    bannerJsonStr: string
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  let bannerImage = newCroppedImage(bannerJsonStr)
  result = callPrivateRPC("createCommunity".prefix, %*[{
      # TODO this will need to be renamed membership (small m)
      "Membership": access,
      "name": name,
      "description": description,
      "introMessage": introMessage,
      "outroMessage": outroMessage,
      "ensOnly": false, # TODO ensOnly is no longer supported. Remove this when we remove it in status-go
      "color": color,
      "tags": parseJson(tags),
      "image": imageUrl,
      "imageAx": aX,
      "imageAy": aY,
      "imageBx": bX,
      "imageBy": bY,
      "historyArchiveSupportEnabled": historyArchiveSupportEnabled,
      "pinMessageAllMembersEnabled": pinMessageAllMembersEnabled,
      "banner": bannerImage
    }])

proc editCommunity*(
    communityId: string,
    name: string,
    description: string,
    introMessage: string,
    outroMessage: string,
    access: int,
    color: string,
    tags: string,
    imageUrl: string,
    aX: int,
    aY: int,
    bX: int,
    bY: int,
    bannerJsonStr: string,
    historyArchiveSupportEnabled: bool,
    pinMessageAllMembersEnabled: bool
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  let bannerImage = newCroppedImage(bannerJsonStr)
  result = callPrivateRPC("editCommunity".prefix, %*[{
    "CommunityID": communityId,
    "membership": access,
    "name": name,
    "description": description,
    "introMessage": introMessage,
    "outroMessage": outroMessage,
    "ensOnly": false, # TODO ensOnly is no longer supported. Remove this when we remove it in status-go
    "color": color,
    "tags": parseJson(tags),
    "image": imageUrl,
    "imageAx": aX,
    "imageAy": aY,
    "imageBx": bX,
    "imageBy": bY,
    "banner": bannerImage,
    "historyArchiveSupportEnabled": historyArchiveSupportEnabled,
    "pinMessageAllMembersEnabled": pinMessageAllMembersEnabled,
  }])

proc requestImportDiscordCommunity*(
    name: string,
    description: string,
    introMessage: string,
    outroMessage: string,
    access: int,
    color: string,
    tags: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int,
    historyArchiveSupportEnabled: bool,
    pinMessageAllMembersEnabled: bool,
    filesToImport: seq[string],
    fromTimestamp: int,
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestImportDiscordCommunity".prefix, %*[{
      # TODO this will need to be renamed membership (small m)
      "Membership": access,
      "name": name,
      "description": description,
      "introMessage": introMessage,
      "outroMessage": outroMessage,
      "ensOnly": false, # TODO ensOnly is no longer supported. Remove this when we remove it in status-go
      "color": color,
      "tags": parseJson(tags),
      "image": imageUrl,
      "imageAx": aX,
      "imageAy": aY,
      "imageBx": bX,
      "imageBy": bY,
      "historyArchiveSupportEnabled": historyArchiveSupportEnabled,
      "pinMessageAllMembersEnabled": pinMessageAllMembersEnabled,
      "from": fromTimestamp,
      "filesToImport": filesToImport
    }])

proc requestImportDiscordChannel*(
    name: string,
    discordChannelId: string,
    communityId: string,
    description: string,
    color: string,
    emoji: string,
    filesToImport: seq[string],
    fromTimestamp: int,
  ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestImportDiscordChannel".prefix, %*[{
      "name": name,
      "discordChannelId": discordChannelId,
      "communityId": communityId,
      "description": description,
      "color": color,
      "emoji": emoji,
      "filesToImport": filesToImport,
      "from": fromTimestamp
    }])

proc createCommunityTokenPermission*(communityId: string, permissionType: int, tokenCriteria: string, chatIDs: seq[string], isPrivate: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("createCommunityTokenPermission".prefix, %*[{
    "communityId": communityId,
    "type": permissionType,
    "tokenCriteria": parseJson(tokenCriteria),
    "chat_ids": chatIDs,
    "isPrivate": isPrivate
  }])

proc editCommunityTokenPermission*(communityId: string, permissionId: string, permissionType: int, tokenCriteria: string, chatIDs: seq[string], isPrivate: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("editCommunityTokenPermission".prefix, %*[{
    "communityId": communityId,
    "permissionId": permissionId,
    "type": permissionType,
    "tokenCriteria": parseJson(tokenCriteria),
    "chat_ids": chatIDs,
    "isPrivate": isPrivate
  }])

proc deleteCommunityTokenPermission*(communityId: string, permissionId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("deleteCommunityTokenPermission".prefix, %*[{
    "communityId": communityId,
    "permissionId": permissionId
  }])

proc requestCancelDiscordCommunityImport*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestCancelDiscordCommunityImport".prefix, %*[communityId])

proc requestCancelDiscordChannelImport*(discordChannelId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestCancelDiscordChannelImport".prefix, %*[discordChannelId])


proc createCommunityChannel*(
    communityId: string,
    name: string,
    description: string,
    emoji: string,
    color: string,
    categoryId: string
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("createCommunityChat".prefix, %*[
    communityId,
    {
      "permissions": {
        "access": 1 # TODO get this from user selected privacy setting
      },
      "identity": {
        "display_name": name,
        "description": description,
        "emoji": emoji,
        "color": color
      },
      "category_id": categoryId
    }])

proc editCommunityChannel*(
    communityId: string,
    channelId: string,
    name: string,
    description: string,
    emoji: string,
    color: string,
    categoryId: string,
    position: int
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("editCommunityChat".prefix, %*[
    communityId,
    channelId.replace(communityId, ""),
    {
      "permissions": {
        "access": 1 # TODO get this from user selected privacy setting
      },
      "identity": {
        "display_name": name,
        "description": description,
        "emoji": emoji,
        "color": color
      },
      "category_id": categoryId,
      "position": position
    }])

proc reorderCommunityCategories*(communityId: string, categoryId: string, position: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("reorderCommunityCategories".prefix, %*[
    {
      "communityId": communityId,
      "categoryId": categoryId,
      "position": position
    }])

proc reorderCommunityChat*(
    communityId: string,
    categoryId: string,
    chatId: string,
    position: int
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("reorderCommunityChat".prefix, %*[
    {
      "communityId": communityId,
      "categoryId": categoryId,
      "chatId": chatId,
      "position": position
    }])

proc deleteCommunityChat*(
    communityId: string,
    chatId: string
    ): RpcResponse[JsonNode] {.raises: [Exception].}  =
  result = callPrivateRPC("deleteCommunityChat".prefix, %*[communityId, chatId])

proc createCommunityCategory*(
    communityId: string,
    name: string,
    channels: seq[string]
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("createCommunityCategory".prefix, %*[
    {
      "communityId": communityId,
      "categoryName": name,
      "chatIds": channels
    }])

proc editCommunityCategory*(
    communityId: string,
    categoryId: string,
    name: string,
    channels: seq[string]
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("editCommunityCategory".prefix, %*[
    {
      "communityId": communityId,
      "categoryId": categoryId,
      "categoryName": name,
      "chatIds": channels
    }])

proc deleteCommunityCategory*(
    communityId: string,
    categoryId: string
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("deleteCommunityCategory".prefix, %*[
    {
      "communityId": communityId,
      "categoryId": categoryId
    }])

proc collectCommunityMetrics*(communityId: string, metricsType: int, intervals: JsonNode
    ):RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("collectCommunityMetrics".prefix, %*[
    {
      "communityId": communityId,
      "type": metricsType,
      "intervals": intervals
    }])

proc requestCommunityInfo*(communityId: string, tryDatabase: bool, shardCluster: int, shardIndex: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  if shardCluster != -1 and shardIndex != -1:
    result = callPrivateRPC("fetchCommunity".prefix,%*[{
      "communityKey": communityId,
      "tryDatabase": tryDatabase,
      "shard": {
        "shardCluster": shardCluster,
        "shardIndex": shardIndex,
      },
      "waitForResponse": true
    }])
  else:
    result = callPrivateRPC("fetchCommunity".prefix, %*[{
      "communityKey": communityId,
      "tryDatabase": tryDatabase,
      "shard": nil,
      "waitForResponse": true
    }])

proc importCommunity*(communityKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("importCommunity".prefix, %*[communityKey])

proc exportCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].}  =
  result = callPrivateRPC("exportCommunity".prefix, %*[communityId])

proc speedupArchivesImport*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("speedupArchivesImport".prefix)

proc slowdownArchivesImport*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("slowdownArchivesImport".prefix)

proc removeUserFromCommunity*(communityId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("removeUserFromCommunity".prefix, %*[communityId, pubKey])

proc acceptRequestToJoinCommunity*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].}  =
  return callPrivateRPC("acceptRequestToJoinCommunity".prefix, %*[{
    "id": requestId
  }])

proc declineRequestToJoinCommunity*(requestId: string): RpcResponse[JsonNode] {.raises: [Exception].}  =
  return callPrivateRPC("declineRequestToJoinCommunity".prefix, %*[{
    "id": requestId
  }])

proc banUserFromCommunity*(communityId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].}  =
  return callPrivateRPC("banUserFromCommunity".prefix, %*[{
    "communityId": communityId,
    "user": pubKey
  }])

proc unbanUserFromCommunity*(communityId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].}  =
  return callPrivateRPC("unbanUserFromCommunity".prefix, %*[{
    "communityId": communityId,
    "user": pubKey
  }])

proc setCommunityMuted*(communityId: string, mutedType: int): RpcResponse[JsonNode] {.raises: [Exception].}  =
  return callPrivateRPC("setCommunityMuted".prefix, %*[{
    "communityId": communityId,
    "mutedType": mutedType
  }])

proc shareCommunityToUsers*(communityId: string, pubKeys: seq[string], inviteMessage: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("shareCommunity".prefix, %*[{
    "communityId": communityId,
    "users": pubKeys,
    "inviteMessage": inviteMessage
  }])

proc shareCommunityUrlWithChatKey*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("shareCommunityURLWithChatKey".prefix, %*[communityId])

proc shareCommunityUrlWithData*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("shareCommunityURLWithData".prefix, %*[communityId])

proc shareCommunityChannelUrlWithChatKey*(communityId: string, channelId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("shareCommunityChannelURLWithChatKey".prefix, %*[{
    "communityId": communityId,
    "channelId": channelId
  }])

proc shareCommunityChannelUrlWithData*(communityId: string, channelId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("shareCommunityChannelURLWithData".prefix, %*[{
    "communityId": communityId,
    "channelId": channelId
  }])

proc getCommunitiesSettings*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("getCommunitiesSettings".prefix, %*[])

proc requestExtractDiscordChannelsAndCategories*(filesToImport: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("requestExtractDiscordChannelsAndCategories".prefix, %*[filesToImport])

proc getCheckChannelPermissionResponses*(communityId: string,): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("getCheckChannelPermissionResponses".prefix, %*[communityId])

proc getCommunityPublicKeyFromPrivateKey*(communityPrivateKey: string,): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("getCommunityPublicKeyFromPrivateKey".prefix, %*[communityPrivateKey])

proc getCommunityMembersForWalletAddresses*(communityId: string, chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("getCommunityMembersForWalletAddresses".prefix, %* [communityId, chainId])

proc promoteSelfToControlNode*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("promoteSelfToControlNode".prefix, %* [communityId])

proc setCommunityShard*(communityId: string, index: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let mainStatusShardClusterID = 16
  if index != -1:
    result = callPrivateRPC("setCommunityShard".prefix, %*[
      {
        "communityId": communityId,
        "shard": {
          "cluster": mainStatusShardClusterID,
          "index": index
        },
      }])
  else: # unset community shard
    result = callPrivateRPC("setCommunityShard".prefix, %*[
      {
        "communityId": communityId,
      }])

