import json
import types
import ../status/libstatus/accounts as status_accounts
import random

proc toMessage*(jsonMsg: JsonNode): Message

proc toChat*(jsonChat: JsonNode): Chat

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

proc toChatMember*(jsonMember: JsonNode): ChatMember =
  result = ChatMember(
    admin: jsonMember["admin"].getBool,
    id: jsonMember["id"].getStr,
    joined: jsonMember["joined"].getBool
  )


const channelColors* = ["#fa6565", "#7cda00", "#887af9", "#51d0f0", "#FE8F59", "#d37ef4"]

proc newChat*(id: string, chatType: ChatType): Chat =
  randomize()
  
  result = Chat(
    id: id,
    color: channelColors[rand(channelColors.len - 1)],
    active: true,
    chatType: chatType,
    timestamp: 0,
    lastClockValue: 0,
    deletedAtClockValue: 0, 
    unviewedMessagesCount: 0
  )

  if chatType == ChatType.OneToOne:
    result.identicon = generateIdenticon(id)
    result.name = generateAlias(id)
  else:
    result.name = id

proc toChat*(jsonChat: JsonNode): Chat =
  result = Chat(
    id: jsonChat{"id"}.getStr,
    name: jsonChat{"name"}.getStr,
    identicon: "",
    color: jsonChat{"color"}.getStr,
    active: jsonChat{"active"}.getBool,
    chatType: ChatType(jsonChat{"chatType"}.getInt),
    timestamp: jsonChat{"timestamp"}.getBiggestInt,
    lastClockValue: jsonChat{"lastClockValue"}.getBiggestInt,
    deletedAtClockValue: jsonChat{"deletedAtClockValue"}.getBiggestInt, 
    unviewedMessagesCount: jsonChat{"unviewedMessagesCount"}.getInt,
  )

  if jsonChat["lastMessage"].kind != JNull: 
    result.lastMessage = jsonChat{"lastMessage"}.toMessage
    if result.chatType == ChatType.OneToOne:
      result.name = result.lastMessage.alias
      result.identicon = result.lastMessage.identicon
  else:
    if result.chatType == ChatType.OneToOne:
      result.identicon = generateIdenticon(result.id)
      result.name = generateAlias(result.id)

  if jsonChat["members"].kind != JNull:
    result.members = @[]
    for jsonMember in jsonChat["members"]:
      result.members.add(jsonMember.toChatMember)

proc toMessage*(jsonMsg: JsonNode): Message =
  result = Message(
      alias: jsonMsg{"alias"}.getStr,
      chatId: jsonMsg{"localChatId"}.getStr,
      clock: jsonMsg{"clock"}.getInt,
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
      isCurrentUser: $jsonMsg{"outgoingStatus"}.getStr == "sending",
      stickerHash: ""
    )

  if result.contentType == 2:
    result.stickerHash = jsonMsg["sticker"]["hash"].getStr


