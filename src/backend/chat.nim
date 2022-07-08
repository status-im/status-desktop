import json, sequtils, sugar, strutils
import core, utils
import response_type

export response_type

proc saveChat*(
    chatId: string,
    chatType: int,
    active: bool = true,
    color: string = "#000000",
    ensName: string = "",
    profile: string = "",
    joined: int64 = 0
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  # TODO: ideally status-go/stimbus should handle some of these fields instead of having the client
  # send them: lastMessage, unviewedMEssagesCount, timestamp, lastClockValue, name?
  return callPrivateRPC("saveChat".prefix, %* [
    {
      "lastClockValue": 0, # TODO:
      "color": color,
      "name": (if ensName != "": ensName else: chatId),
      "lastMessage": nil, # TODO:
      "active": active,
      "profile": profile,
      "id": chatId,
      "unviewedMessagesCount": 0, # TODO:
      "chatType":  chatType.int,
      "timestamp": 1588940692659,  # TODO:
      "joined": joined
    }
  ])

proc getChats*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("chat_getChats", payload)

proc createPublicChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let communityId = ""
  let payload = %* [communityId, chatId]
  result = callPrivateRPC("chat_joinChat", payload)

proc createOneToOneChat*(chatId: string, ensName: string = ""): RpcResponse[JsonNode] {.raises: [Exception].} =
  let communityId = ""
  let payload = %* [communityId, chatId, ensName]
  result = callPrivateRPC("chat_createOneToOneChat", payload)

proc leaveGroupChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("leaveGroupChat".prefix, %* [nil, chatId, true])

proc deactivateChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("deactivateChat".prefix, %* [{ "ID": chatId }])

proc clearChatHistory*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("clearHistory".prefix, %* [{ "id": chatId }])

proc sendChatMessage*(
    chatId: string,
    msg: string,
    replyTo: string,
    contentType: int,
    preferredUsername: string = "",
    communityId: string = "",
    stickerHash: string = "",
    stickerPack: string = "0",
    ): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("sendChatMessage".prefix, %* [
    {
      "chatId": chatId,
      "text": msg,
      "responseTo": replyTo,
      "ensName": preferredUsername,
      "sticker": {
        "hash": stickerHash,
        "pack": parseInt(stickerPack)
      },
      "contentType": contentType,
      "communityId": communityId
    }
  ])

proc sendImages*(chatId: string, images: var seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let imagesJson = %* images.map(image => %*
      {
        "chatId": chatId,
        "contentType": 7, # TODO how do we unhardcode this
        "imagePath": image,
        # TODO is this still needed
        # "ensName": preferredUsername,
        "text": "Please upgrade your status version to view images"
      }
    )
  callPrivateRPC("sendChatMessages".prefix, %* [imagesJson])

proc muteChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId]
  result = callPrivateRPC("muteChat".prefix, payload)

proc unmuteChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId]
  result = callPrivateRPC("unmuteChat".prefix, payload)

proc deleteMessagesByChatId*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId]
  result = callPrivateRPC("deleteMessagesByChatID".prefix, payload)

proc addGroupMembers*(communityID: string, chatId: string, pubKeys: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, communityID, chatId, pubKeys]
  result = callPrivateRPC("addMembersToGroupChat".prefix, payload)

proc removeMemberFromGroupChat*(communityID: string, chatId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, communityID, chatId, pubKey]
  result = callPrivateRPC("removeMemberFromGroupChat".prefix, payload)

proc renameGroupChat*(communityID: string, chatId: string, newName: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, communityID, chatId, newName]
  result = callPrivateRPC("changeGroupChatName".prefix, payload)

proc makeAdmin*(communityID: string, chatId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, communityID, chatId, [pubKey]]
  result = callPrivateRPC("addAdminsToGroupChat".prefix, payload)

proc createGroupChat*(communityID: string, groupName: string, pubKeys: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, communityID, groupName, pubKeys]
  result = callPrivateRPC("createGroupChatWithMembers".prefix, payload)

proc createGroupChatFromInvitation*(groupName: string, chatId: string, adminPK: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [groupName, chatId, adminPK]
  result = callPrivateRPC("createGroupChatFromInvitation".prefix, payload)

proc getLinkPreviewData*(link: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("getLinkPreviewData".prefix, %* [link])

proc getMembers*(communityId, chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("chat_getMembers", %* [communityId, chatId])
