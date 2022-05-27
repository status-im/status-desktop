{.used.}

import json, strformat, strutils, stint, json_serialization
import ../../message/dto/message

include ../../../common/json_utils
include ../../../common/utils

type ActivityCenterNotificationType* {.pure.}= enum
  Unknown = 0,
  NewOneToOne = 1,
  NewPrivateGroupChat = 2,
  Mention = 3,
  Reply = 4,
  ContactRequest = 5

type ActivityCenterNotificationDto* = ref object of RootObj
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  chatId*: string
  name*: string
  author*: string
  notificationType*: ActivityCenterNotificationType
  message*: MessageDto
  timestamp*: int64
  read*: bool
  dismissed*: bool
  accepted*: bool

proc `$`*(self: ActivityCenterNotificationDto): string =
  result = fmt"""ActivityCenterNotificationDto(
    id: {$self.id},
    chatId: {self.chatId},
    author: {self.author},
    notificationType: {$self.notificationType.int},
    timestamp: {self.timestamp},
    read: {$self.read},
    dismissed: {$self.dismissed},
    accepted: {$self.accepted},
    message:{self.message}
    )"""

proc toActivityCenterNotificationDto*(jsonObj: JsonNode): ActivityCenterNotificationDto =
  result = ActivityCenterNotificationDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("author", result.author)

  result.notificationType = ActivityCenterNotificationType.Unknown
  var notificationTypeInt: int
  if (jsonObj.getProp("type", notificationTypeInt) and
    (notificationTypeInt >= ord(low(ActivityCenterNotificationType)) or
    notificationTypeInt <= ord(high(ActivityCenterNotificationType)))):
      result.notificationType = ActivityCenterNotificationType(notificationTypeInt)

  discard jsonObj.getProp("timestamp", result.timestamp)
  discard jsonObj.getProp("read", result.read)
  discard jsonObj.getProp("dismissed", result.dismissed)
  discard jsonObj.getProp("accepted", result.accepted)

  if jsonObj.contains("message") and jsonObj{"message"}.kind != JNull:
    result.message = jsonObj{"message"}.toMessageDto()
  elif result.notificationType == ActivityCenterNotificationType.NewOneToOne and
    jsonObj.contains("lastMessage") and jsonObj{"lastMessage"}.kind != JNull:
    result.message = jsonObj{"lastMessage"}.toMessageDto()


proc parseActivityCenterNotifications*(rpcResult: JsonNode): (string, seq[ActivityCenterNotificationDto]) =
  var notifs: seq[ActivityCenterNotificationDto] = @[]
  if rpcResult{"notifications"}.kind != JNull:
    for jsonMsg in rpcResult["notifications"]:
      notifs.add(jsonMsg.toActivityCenterNotificationDto())
  return (rpcResult{"cursor"}.getStr, notifs)

