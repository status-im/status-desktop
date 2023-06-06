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

proc requestToJoinCommunity*(communityId: string, ensName: string, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  var passwordToSend = password
  result = callPrivateRPC("requestToJoinCommunity".prefix, %*[{
    "communityId": communityId,
    "ensName": ensName,
    "password": if passwordToSend != "": utils.hashPassword(password) else: ""
  }])

proc checkPermissionsToJoinCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("checkPermissionsToJoinCommunity".prefix, %*[{
    "communityId": communityId
  }])

proc myPendingRequestsToJoin*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result =  callPrivateRPC("myPendingRequestsToJoin".prefix)

proc myCanceledRequestsToJoin*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result =  callPrivateRPC("myCanceledRequestsToJoin".prefix)

proc pendingRequestsToJoinForCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("pendingRequestsToJoinForCommunity".prefix, %*[communityId])

proc declinedRequestsToJoinForCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("declinedRequestsToJoinForCommunity".prefix, %*[communityId])

proc canceledRequestsToJoinForCommunity*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("canceledRequestsToJoinForCommunity".prefix, %*[communityId])

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

proc createCommunityTokenPermission*(communityId: string, permissionType: int, tokenCriteria: string, isPrivate: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("createCommunityTokenPermission".prefix, %*[{
    "communityId": communityId,
    "type": permissionType,
    "tokenCriteria": parseJson(tokenCriteria),
    "isPrivate": isPrivate
  }])

proc editCommunityTokenPermission*(communityId: string, permissionId: string, permissionType: int, tokenCriteria: string, isPrivate: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("editCommunityTokenPermission".prefix, %*[{
    "communityId": communityId,
    "permissionId": permissionId,
    "type": permissionType,
    "tokenCriteria": parseJson(tokenCriteria),
    "isPrivate": isPrivate
  }])

proc deleteCommunityTokenPermission*(communityId: string, permissionId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("deleteCommunityTokenPermission".prefix, %*[{
    "communityId": communityId,
    "permissionId": permissionId
  }])
  
proc requestCancelDiscordCommunityImport*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestCancelDiscordCommunityImport".prefix, %*[communityId])

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

proc requestCommunityInfo*(communityId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("requestCommunityInfoFromMailserver".prefix, %*[communityId])

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

proc setCommunityMuted*(communityId: string, muted: bool): RpcResponse[JsonNode] {.raises: [Exception].}  =
  return callPrivateRPC("setCommunityMuted".prefix, %*[communityId, muted])

proc inviteUsersToCommunity*(communityId: string, pubKeys: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("inviteUsersToCommunity".prefix, %*[{
    "communityId": communityId,
    "users": pubKeys
  }])

proc shareCommunityToUsers*(communityId: string, pubKeys: seq[string], inviteMessage: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("shareCommunity".prefix, %*[{
    "communityId": communityId,
    "users": pubKeys,
    "inviteMessage": inviteMessage
  }])

proc getCommunitiesSettings*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("getCommunitiesSettings".prefix, %*[])

proc requestExtractDiscordChannelsAndCategories*(filesToImport: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("requestExtractDiscordChannelsAndCategories".prefix, %*[filesToImport])

