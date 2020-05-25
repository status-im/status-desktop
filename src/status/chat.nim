import core
import json
import utils

proc loadFilters*(chatId: string, filterId: string = "", symKeyId: string = "", oneToOne: bool = false, identity: string = "", topic: string = "", discovery: bool = false, negotiated: bool = false, listen: bool = true) =
  discard callPrivateRPC("loadFilters".prefix, %* [
    [{
      "ChatID": chatId, # identifier of the chat
      "FilterID": filterId, # whisper filter id generated
      "SymKeyID": symKeyId, # symmetric key id used for symmetric filters
      "OneToOne": oneToOne, # if asymmetric encryption is used for this chat
      "Identity": identity, # public key of the other recipient for non-public filters.
      "Topic": topic, # whisper topic
      "Discovery": discovery, 
      "Negotiated": negotiated,
      "Listen": listen # whether we are actually listening for messages on this chat, or the filter is only created in order to be able to post on the topic
    }]
  ])

proc saveChat*(chatId: string, oneToOne = false) =
  discard callPrivateRPC("saveChat".prefix, %* [
    {
      "lastClockValue": 0,
      "color": "#51d0f0",
      "name": chatId,
      "lastMessage": nil,
      "active": true,
      "id": chatId,
      "unviewedMessagesCount": 0,
      "chatType":  if oneToOne: 1 else: 2,
      "timestamp": 1588940692659
    }
  ])

proc chatMessages*(chatId: string) =
  discard callPrivateRPC("chatMessages".prefix, %* [chatId, nil, 20])

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
