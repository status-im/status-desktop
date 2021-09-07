{.used.}

import json, chronicles
import message

export message

type ActivityCenterNotificationType* {.pure.}= enum
  Unknown = 0,
  NewOneToOne = 1, 
  NewPrivateGroupChat = 2,
  Mention = 3
  Reply = 4

type ActivityCenterNotification* = ref object of RootObj
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  chatId*: string
  name*: string
  author*: string
  notificationType*: ActivityCenterNotificationType
  message*: Message
  timestamp*: int64
  read*: bool
  dismissed*: bool
  accepted*: bool

proc toActivityCenterNotification*(jsonNotification: JsonNode): ActivityCenterNotification =
  var activityCenterNotificationType: ActivityCenterNotificationType
  try:
    activityCenterNotificationType = ActivityCenterNotificationType(jsonNotification{"type"}.getInt)
  except:
    warn "Unknown notification type received", type = jsonNotification{"type"}.getInt
    activityCenterNotificationType = ActivityCenterNotificationType.Unknown
  result = ActivityCenterNotification(
      id: jsonNotification{"id"}.getStr,
      chatId: jsonNotification{"chatId"}.getStr,
      name: jsonNotification{"name"}.getStr,
      author: jsonNotification{"author"}.getStr,
      notificationType: activityCenterNotificationType,
      timestamp: jsonNotification{"timestamp"}.getInt,
      read: jsonNotification{"read"}.getBool,
      dismissed: jsonNotification{"dismissed"}.getBool,
      accepted: jsonNotification{"accepted"}.getBool
    )

  if jsonNotification.contains("message") and jsonNotification{"message"}.kind != JNull: 
    result.message = jsonNotification{"message"}.toMessage()
  elif activityCenterNotificationType == ActivityCenterNotificationType.NewOneToOne and jsonNotification.contains("lastMessage") and jsonNotification{"lastMessage"}.kind != JNull:
    result.message = jsonNotification{"lastMessage"}.toMessage()