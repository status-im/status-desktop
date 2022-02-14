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
  result = callPrivateRPC("chats".prefix, payload)

proc createPublicChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{"ID": chatId}]
  result = callPrivateRPC("createPublicChat".prefix, payload)

proc createOneToOneChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{"ID": chatId}]
  result = callPrivateRPC("createOneToOneChat".prefix, payload)

proc leaveGroupChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("leaveGroupChat".prefix, %* [nil, chatId, true])

proc deactivateChat*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("deactivateChat".prefix, %* [{ "ID": chatId }])

proc clearChatHistory*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("deleteMessagesByChatID".prefix, %* [chatId])

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
        "text": "Update to latest version to see a nice image here!"
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

proc addGroupMembers*(chatId: string, pubKeys: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, chatId, pubKeys]
  result = callPrivateRPC("addMembersToGroupChat".prefix, payload)

proc removeMembersFromGroupChat*(chatId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, chatId, pubKey]
  result = callPrivateRPC("removeMemberFromGroupChat".prefix, payload)

proc renameGroupChat*(chatId: string, newName: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, chatId, newName]
  result = callPrivateRPC("changeGroupChatName".prefix, payload)

proc makeAdmin*(chatId: string, pubKey: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, chatId, [pubKey]]
  result = callPrivateRPC("addAdminsToGroupChat".prefix, payload)

proc createGroupChat*(groupName: string, pubKeys: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [nil, groupName, pubKeys]
  result = callPrivateRPC("createGroupChatWithMembers".prefix, payload)

proc confirmJoiningGroup*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId]
  result = callPrivateRPC("confirmJoiningGroup".prefix, payload)

proc createGroupChatFromInvitation*(groupName: string, chatId: string, adminPK: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [groupName, chatId, adminPK]
  result = callPrivateRPC("createGroupChatFromInvitation".prefix, payload)

proc getLinkPreviewData*(link: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("getLinkPreviewData".prefix, %* [link])
