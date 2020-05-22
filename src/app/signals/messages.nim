import json
import types

proc toMessage(jsonMsg: JsonNode): Message
proc toChat(jsonChat: JsonNode): Chat

proc fromEvent*(event: JsonNode): Signal = 
  var signal:MessageSignal = MessageSignal()
  signal.messages = @[]

  if event["event"]{"messages"} != nil:
    for jsonMsg in event["event"]["messages"]:
      signal.messages.add(jsonMsg.toMessage)

  if event["event"]{"chats"} != nil:
    for jsonChat in event["event"]["chats"]:
      signal.chats.add(jsonChat.toChat)

  result = signal

proc toChat(jsonChat: JsonNode): Chat =
  result = Chat(
    id: jsonChat{"id"}.getStr,
    name: jsonChat{"name"}.getStr,
    color: jsonChat{"color"}.getStr,
    active: jsonChat{"active"}.getBool,
    chatType: ChatType(jsonChat{"chatType"}.getInt),
    timestamp: jsonChat{"timestamp"}.getBiggestInt,
    lastClockValue: jsonChat{"lastClockValue"}.getBiggestInt,
    deletedAtClockValue: jsonChat{"deletedAtClockValue"}.getBiggestInt, 
    unviewedMessagesCount: jsonChat{"unviewedMessagesCount"}.getInt,
    lastMessage: jsonChat{"lastMessage"}.toMessage
  )


proc toMessage(jsonMsg: JsonNode): Message =
  result = Message(
      alias: jsonMsg{"alias"}.getStr,
      chatId: jsonMsg{"chatId"}.getStr,
      clock: $jsonMsg{"clock"}.getInt,
      contentType: jsonMsg{"contentType"}.getInt,
      ensName: jsonMsg{"ensName"}.getStr,
      fromAuthor: jsonMsg{"from"}.getStr,
      id: jsonMsg{"identicon"}.getStr,
      identicon: jsonMsg{"identicon"}.getStr,
      lineCount: jsonMsg{"lineCount"}.getInt,
      localChatId: jsonMsg{"localChatId"}.getStr,
      messageType: jsonMsg{"messageType"}.getStr,
      replace: jsonMsg{"replace"}.getStr,
      responseTo: jsonMsg{"responseTo"}.getStr,
      rtl: jsonMsg{"rtl"}.getBool,
      seen: jsonMsg{"seen"}.getBool,
      text: jsonMsg{"text"}.getStr,
      timestamp: $jsonMsg{"timestamp"}.getInt,
      whisperTimestamp: $jsonMsg{"whisperTimestamp"}.getInt,
      isCurrentUser: false # TODO: this must compare the fromAuthor against current user because the messages received from the mailserver will arrive as signals too, and those include the current user messages
    )