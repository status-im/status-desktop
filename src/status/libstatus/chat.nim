import core
import json
import utils
import times
import strutils
import sequtils
import chronicles
import ../chat/[chat, message]
import ../../signals/messages

proc buildFilter*(chat: Chat):JsonNode =
  if chat.chatType == ChatType.PrivateGroupChat:
    return newJNull()
  result = %* {
    "ChatID": chat.id,
    "OneToOne": chat.chatType == ChatType.OneToOne
  }

proc loadFilters*(filters: seq[JsonNode]): string =
  result =  callPrivateRPC("loadFilters".prefix, %* [filter(filters, proc(x:JsonNode):bool = x.kind != JNull)])

proc removeFilters*(chatId: string, filterId: string) =
  discard callPrivateRPC("removeFilters".prefix, %* [
    [{
      "ChatID": chatId,
      "FilterID": filterId
    }]
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

proc loadChats*(): seq[Chat] =
  result = @[]
  let jsonResponse = parseJson($callPrivateRPC("chats".prefix))
  if jsonResponse["result"].kind != JNull:
    for jsonChat in jsonResponse{"result"}:
      let chat = jsonChat.toChat
      if chat.isActive and chat.chatType != ChatType.Unknown:
        result.add(jsonChat.toChat)

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

# TODO this probably belongs in another file
proc generateSymKeyFromPassword*(): string =
  result = ($parseJson(callPrivateRPC("waku_generateSymKeyFromPassword", %* [
    # TODO unhardcode this for non-status mailservers
    "status-offline-inbox"
  ]))["result"]).strip(chars = {'"'})

proc sendChatMessage*(chatId: string, msg: string): string =
  callPrivateRPC("sendChatMessage".prefix, %* [
    {
      "chatId": chatId,
      "text": msg,
      "responseTo": nil,
      "ensName": nil,
      "sticker": nil,
      "contentType": 1
    }
  ])

proc markAllRead*(chatId: string): string =
  callPrivateRPC("markAllRead".prefix, %* [chatId])

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