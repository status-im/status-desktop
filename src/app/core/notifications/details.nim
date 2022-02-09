{.used.}

import json

include ../../../app_service/common/json_utils

type
  NotificationType* {.pure.} = enum
    NewContactRequest = 1,
    AcceptedContactRequest,
    JoinCommunityRequest,
    MyRequestToJoinCommunityAccepted,
    MyRequestToJoinCommunityRejected,
    NewMessage,
    NewMention

  NotificationDetails* = object
    notificationType*: NotificationType
    sectionId*: string
    chatId*: string
    messageId*: string

proc toNotificationDetails*(jsonObj: JsonNode): NotificationDetails =
  var notificationType: int
  if (not (jsonObj.getProp("notificationType", notificationType) and 
    jsonObj.getProp("sectionId", result.sectionId) and
    jsonObj.getProp("chatId", result.chatId) and 
    jsonObj.getProp("messageId", result.messageId))):
    return NotificationDetails()

  result.notificationType = notificationType.NotificationType

proc toJsonNode*(self: NotificationDetails): JsonNode =
  result = %* {
    "notificationType": self.notificationType.int,
    "sectionId": self.sectionId,
    "chatId": self.chatId,
    "messageId": self.messageId
  }
