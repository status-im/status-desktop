import libstatus
import json
import utils

proc startMessenger*() =
  let payload = %* {
    "jsonrpc": "2.0",
    "id": 3, #TODO:
    "method": "startMessenger".prefix,
    "params": []
  }
  discard $libstatus.callPrivateRPC($payload)
  # TODO: create template for error handling

proc loadFilters*(chatId: string) =
  let payload = %* {
    "jsonrpc": "2.0",
    "id": 3, #TODO:
    "method": "loadFilters".prefix,
    "params": [
      [{
        "ChatID": chatId,
        "OneToOne": false
      }]
    ]
  }
  discard $libstatus.callPrivateRPC($payload)

proc saveChat*(chatId: string) =
  let payload = %* {
    "jsonrpc": "2.0",
    "id": 4,
    "method": "saveChat".prefix,
    "params": [ #TODO: determine where do these values come from
      {
        "lastClockValue": 0,
        "color": "#51d0f0",
        "name": chatId,
        "lastMessage": nil,
        "active": true,
        "id": chatId,
        "unviewedMessagesCount": 0,
        "chatType": 2,
        "timestamp": 1588940692659
      }
    ]
  }
  discard $libstatus.callPrivateRPC($payload)

proc chatMessages*(chatId: string) =
  let payload = %* {
    "jsonrpc": "2.0",
    "id": 3, #TODO:
    "method": "chatMessages".prefix,
    "params": [
      chatId, nil, 20
    ]
  }
  discard $libstatus.callPrivateRPC($payload)
  # TODO: create template for error handling

proc sendPublicChatMessage*(chatId: string, msg: string): string =
  let payload = %* {
    "jsonrpc": "2.0",
    "id": 40,
    "method": "sendChatMessage".prefix,
    "params": [
      {
        "chatId": chatId,
        "text": msg,
        "responseTo": nil,
        "ensName": nil,
        "sticker": nil,
        "contentType": 1
      }
    ]
  }
  $libstatus.callPrivateRPC($payload)
