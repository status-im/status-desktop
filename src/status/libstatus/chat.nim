import json, times, strutils, sequtils, chronicles, json_serialization, algorithm
import core, utils
import ../chat/[chat, message]
import ../signals/messages
import ./types
import ./settings

proc buildFilter*(chat: Chat):JsonNode =
  if chat.chatType == ChatType.PrivateGroupChat:
    return newJNull()
  result = %* { "ChatID": chat.id, "OneToOne": chat.chatType == ChatType.OneToOne }

proc loadFilters*(filters: seq[JsonNode]): string =
  result =  callPrivateRPC("loadFilters".prefix, %* [filter(filters, proc(x:JsonNode):bool = x.kind != JNull)])

proc removeFilters*(chatId: string, filterId: string) =
  discard callPrivateRPC("removeFilters".prefix, %* [
    [{ "ChatID": chatId, "FilterID": filterId }]
  ])

proc saveChat*(chatId: string, oneToOne: bool = false, active: bool = true, color: string) =
  # TODO: ideally status-go/stimbus should handle some of these fields instead of having the client
  # send them: lastMessage, unviewedMEssagesCount, timestamp, lastClockValue, name?
  discard callPrivateRPC("saveChat".prefix, %* [
    {
      "lastClockValue": 0, # TODO:
      "color": color,
      "name": chatId,
      "lastMessage": nil, # TODO:
      "active": active,
      "id": chatId,
      "unviewedMessagesCount": 0, # TODO:
      "chatType":  if oneToOne: 1 else: 2,  # TODO: use constants
      "timestamp": 1588940692659  # TODO:
    }
  ])

proc deactivateChat*(chat: Chat) =
  chat.isActive = false
  discard callPrivateRPC("saveChat".prefix, %* [chat.toJsonNode])

proc sortChats(x, y: Chat): int = 
  if x.lastMessage.whisperTimestamp > y.lastMessage.whisperTimestamp: 1
  elif x.lastMessage.whisperTimestamp == y.lastMessage.whisperTimestamp: 0
  else: -1

proc loadChats*(): seq[Chat] =
  result = @[]
  let jsonResponse = parseJson($callPrivateRPC("chats".prefix))
  if jsonResponse["result"].kind != JNull:
    for jsonChat in jsonResponse{"result"}:
      let chat = jsonChat.toChat
      if chat.isActive and chat.chatType != ChatType.Unknown:
        result.add(jsonChat.toChat)
  result.sort(sortChats)

proc chatMessages*(chatId: string, cursor: string = ""): (string, seq[Message]) =
  var messages: seq[Message] = @[]
  var cursorVal: JsonNode
  
  if cursor == "":
    cursorVal = newJNull()
  else:
    cursorVal = newJString(cursor)

  let rpcResult = parseJson(callPrivateRPC("chatMessages".prefix, %* [chatId, cursorVal, 20]))["result"]
  if rpcResult["messages"].kind != JNull:
    for jsonMsg in rpcResult["messages"]:
      messages.add(jsonMsg.toMessage)

  return (rpcResult{"cursor"}.getStr, messages)


proc getEmojiReactionsByChatId*(chatId: string, cursor: string = ""): (string, seq[Reaction]) =
  var reactions: seq[Reaction] = @[]
  var cursorVal: JsonNode
  
  if cursor == "":
    cursorVal = newJNull()
  else:
    cursorVal = newJString(cursor)

  let rpcResult = parseJson(callPrivateRPC("emojiReactionsByChatID".prefix, %* [chatId, cursorVal, 20]))["result"]

  if rpcResult != nil and rpcResult.len != 0:
    for jsonMsg in rpcResult:
      reactions.add(jsonMsg.toReaction)

  return (rpcResult{"cursor"}.getStr, reactions)

proc addEmojiReaction*(chatId: string, messageId: string, emojiId: int): seq[Reaction] =
  let rpcResult = parseJson(callPrivateRPC("sendEmojiReaction".prefix, %* [chatId, messageId, emojiId]))["result"]
  
  var reactions: seq[Reaction] = @[]
  if rpcResult != nil and rpcResult["emojiReactions"] != nil and rpcResult["emojiReactions"].len != 0:
    for jsonMsg in rpcResult["emojiReactions"]:
      reactions.add(jsonMsg.toReaction)
  
  result = reactions

proc removeEmojiReaction*(emojiReactionId: string): seq[Reaction] =
  let rpcResult = parseJson(callPrivateRPC("sendEmojiReactionRetraction".prefix, %* [emojiReactionId]))["result"]
 
  var reactions: seq[Reaction] = @[]
  if rpcResult != nil and rpcResult["emojiReactions"] != nil and rpcResult["emojiReactions"].len != 0:
    for jsonMsg in rpcResult["emojiReactions"]:
      reactions.add(jsonMsg.toReaction)
  
  result = reactions

# TODO this probably belongs in another file
proc generateSymKeyFromPassword*(): string =
  result = ($parseJson(callPrivateRPC("waku_generateSymKeyFromPassword", %* [
    # TODO unhardcode this for non-status mailservers
    "status-offline-inbox"
  ]))["result"]).strip(chars = {'"'})

proc sendChatMessage*(chatId: string, msg: string, replyTo: string, contentType: int): string =
  let preferredUsername = getSetting[string](Setting.PreferredUsername, "")
  callPrivateRPC("sendChatMessage".prefix, %* [
    {
      "chatId": chatId,
      "text": msg,
      "responseTo": replyTo,
      "ensName": preferredUsername,
      "sticker": nil,
      "contentType": contentType
    }
  ])

proc sendImageMessage*(chatId: string, image: string): string =
  let preferredUsername = getSetting[string](Setting.PreferredUsername, "")
  callPrivateRPC("sendChatMessage".prefix, %* [
    {
      "chatId": chatId,
      "contentType": ContentType.Image.int,
      "imagePath": image,
      "ensName": preferredUsername,
      "text": "Update to latest version to see a nice image here!"
    }
  ])

proc sendStickerMessage*(chatId: string, sticker: Sticker): string =
  let preferredUsername = getSetting[string](Setting.PreferredUsername, "")
  callPrivateRPC("sendChatMessage".prefix, %* [
    {
      "chatId": chatId,
      "text": "Update to latest version to see a nice sticker here!",
      "responseTo": nil,
      "ensName": preferredUsername,
      "sticker": {
        "hash": sticker.hash,
        "pack": sticker.packId
      },
      "contentType": ContentType.Sticker.int
    }
  ])

proc markAllRead*(chatId: string): string =
  callPrivateRPC("markAllRead".prefix, %* [chatId])

proc markMessagesSeen*(chatId: string, messageIds: seq[string]): string =
  callPrivateRPC("markMessagesSeen".prefix, %* [chatId, messageIds])

proc confirmJoiningGroup*(chatId: string): string =
  callPrivateRPC("confirmJoiningGroup".prefix, %* [chatId])

proc leaveGroupChat*(chatId: string): string =
  callPrivateRPC("leaveGroupChat".prefix, %* [nil, chatId, true])

proc clearChatHistory*(chatId: string): string =
  callPrivateRPC("deleteMessagesByChatID".prefix, %* [chatId])

proc renameGroup*(chatId: string, newName: string): string =
  callPrivateRPC("changeGroupChatName".prefix, %* [nil, chatId, newName])

proc createGroup*(groupName: string, pubKeys: seq[string]): string =
  callPrivateRPC("createGroupChatWithMembers".prefix, %* [nil, groupName, pubKeys])

proc addGroupMembers*(chatId: string, pubKeys: seq[string]): string =
  callPrivateRPC("addMembersToGroupChat".prefix, %* [nil, chatId, pubKeys])

proc kickGroupMember*(chatId: string, pubKey: string): string =
  callPrivateRPC("removeMemberFromGroupChat".prefix, %* [nil, chatId, pubKey])

proc makeAdmin*(chatId: string, pubKey: string): string =
  callPrivateRPC("addAdminsToGroupChat".prefix, %* [nil, chatId, [pubKey]])

proc updateOutgoingMessageStatus*(messageId: string, status: string): string =
  result = callPrivateRPC("updateMessageOutgoingStatus".prefix, %* [messageId, status])
  # TODO: handle errors

proc reSendChatMessage*(messageId: string): string =
  result = callPrivateRPC("reSendChatMessage".prefix, %*[messageId])

proc muteChat*(chatId: string): string =
  result = callPrivateRPC("muteChat".prefix, %*[chatId])

proc unmuteChat*(chatId: string): string =
  result = callPrivateRPC("unmuteChat".prefix, %*[chatId])

proc getLinkPreviewData*(link: string): JsonNode =
  result = callPrivateRPC("getLinkPreviewData".prefix, %*[link]).parseJSON()["result"]