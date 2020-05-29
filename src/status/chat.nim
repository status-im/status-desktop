import core
import json
import utils
import times
import strutils
import chronicles
import ../signals/types
import ../signals/messages

proc loadFilters*(chatId: string, filterId: string = "", symKeyId: string = "", oneToOne: bool = false, identity: string = "", topic: string = "", discovery: bool = false, negotiated: bool = false, listen: bool = true): string =
  result =  callPrivateRPC("loadFilters".prefix, %* [
    [{
      "ChatID": chatId, # identifier of the chat
      "FilterID": filterId, # whisper filter id generated
      "SymKeyID": symKeyId, # symmetric key id used for symmetric filters
      "OneToOne": oneToOne, # if asymmetric encryption is used for this chat
      "Identity": identity, # public key of the other recipient for non-public filters.
      # FIXME: passing empty string to the topic makes it error
      # "Topic": topic, # whisper topic
      "Discovery": discovery,
      "Negotiated": negotiated,
      "Listen": listen # whether we are actually listening for messages on this chat, or the filter is only created in order to be able to post on the topic
    }]
  ])

proc removeFilters*(chatId: string, filterId: string) =
  discard callPrivateRPC("removeFilters".prefix, %* [
    [{
      "ChatID": chatId,
      "FilterID": filterId
    }]
  ])

proc saveChat*(chatId: string, oneToOne: bool = false, active: bool = true) =
  discard callPrivateRPC("saveChat".prefix, %* [
    {
      "lastClockValue": 0, # TODO:
      "color": "#51d0f0", # TODO:
      "name": chatId,
      "lastMessage": nil, # TODO:
      "active": active,
      "id": chatId,
      "unviewedMessagesCount": 0, # TODO:
      # TODO use constants for those too or use the Date
      "chatType":  if oneToOne: 1 else: 2,  # TODO: use constants
      "timestamp": 1588940692659  # TODO:
    }
  ])

proc inactivateChat*(chatId: string) =
  discard callPrivateRPC("saveChat".prefix, %* [
    {
      "lastClockValue": 0,
      "color": "",
      "name": chatId,
      "lastMessage": nil,
      "active": false,
      "id": chatId,
      "unviewedMessagesCount": 0,
      "timestamp": 0
    }
  ])

proc loadChats*(): seq[Chat] =
  result = @[]
  let jsonResponse = parseJson($callPrivateRPC("chats".prefix))
  if jsonResponse["result"].kind != JNull:
    for jsonChat in jsonResponse{"result"}:
      let chat = jsonChat.toChat
      if chat.active: result.add(jsonChat.toChat)

proc chatMessages*(chatId: string) =
  discard callPrivateRPC("chatMessages".prefix, %* [chatId, nil, 20])

# TODO this probably belongs in another file
proc generateSymKeyFromPassword*(): string =
  result = ($parseJson(callPrivateRPC("waku_generateSymKeyFromPassword", %* [
    # TODO unhardcode this for non-status mailservers
    "status-offline-inbox"
  ]))["result"]).strip(chars = {'"'})

proc requestMessages*(topics: seq[string], symKeyID: string, peer: string, numberOfMessages: int) =
  discard callPrivateRPC("requestMessages".prefix, %* [
    {
        "topics": topics,
        "mailServerPeer": peer,
        "symKeyID": symKeyID,
        "timeout": 30,
        "limit": numberOfMessages,
        "cursor": nil,
        "from": times.toUnix(times.getTime()) - 30000 # Unhardcode this. Need to keep the last fetch in a DB
    }
  ])


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
