import core
import json
import utils

proc loadFilters*(chatId: string, oneToOne = false) =
  discard callPrivateRPC("loadFilters".prefix, %* [
    [{
      "ChatID": chatId,
      "OneToOne": oneToOne
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
