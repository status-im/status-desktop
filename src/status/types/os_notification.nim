{.used.}

import json

import ../../eventemitter

type 
  OsNotificationType* {.pure.} = enum
    NewContactRequest = 1,
    AcceptedContactRequest,
    JoinCommunityRequest,
    AcceptedIntoCommunity,
    RejectedByCommunity,
    NewMessage

  OsNotificationDetails* = object
    notificationType*: OsNotificationType
    communityId*: string
    channelId*: string
    messageId*: string

type 
  OsNotificationsArgs* = ref object of Args
    details*: OsNotificationDetails

proc toOsNotificationDetails*(json: JsonNode): OsNotificationDetails =
  if (not (json.contains("notificationType") and
    json.contains("communityId") and
    json.contains("channelId") and
    json.contains("messageId"))):
    return OsNotificationDetails()

  return OsNotificationDetails(
    notificationType: json{"notificationType"}.getInt.OsNotificationType,
    communityId: json{"communityId"}.getStr,
    channelId: json{"channelId"}.getStr,
    messageId: json{"messageId"}.getStr
  )

proc toJsonNode*(self: OsNotificationDetails): JsonNode =
  result = %* {
    "notificationType": self.notificationType.int,
    "communityId": self.communityId,
    "channelId": self.channelId,
    "messageId": self.messageId
  }