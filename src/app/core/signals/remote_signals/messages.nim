import json

import base

import status/types/[message, chat, community, profile, installation,
  activity_center_notification, status_update, removed_message]

type MessageSignal* = ref object of Signal
  messages*: seq[Message]
  pinnedMessages*: seq[Message]
  chats*: seq[Chat]
  contacts*: seq[Profile]
  installations*: seq[Installation]
  emojiReactions*: seq[Reaction]
  communities*: seq[Community]
  membershipRequests*: seq[CommunityMembershipRequest]
  activityCenterNotification*: seq[ActivityCenterNotification]
  statusUpdates*: seq[StatusUpdate]
  deletedMessages*: seq[RemovedMessage]

proc fromEvent*(T: type MessageSignal, event: JsonNode): MessageSignal = 
  var signal:MessageSignal = MessageSignal()
  signal.messages = @[]
  signal.contacts = @[]

  if event["event"]{"contacts"} != nil:
    for jsonContact in event["event"]["contacts"]:
      signal.contacts.add(jsonContact.toProfile())

  var chatsWithMentions: seq[string] = @[]

  if event["event"]{"messages"} != nil:
    for jsonMsg in event["event"]["messages"]:
      var message = jsonMsg.toMessage()
      if message.hasMention:
        chatsWithMentions.add(message.chatId)
      signal.messages.add(message)

  if event["event"]{"chats"} != nil:
    for jsonChat in event["event"]["chats"]:
      var chat = jsonChat.toChat
      if chatsWithMentions.contains(chat.id):
        chat.mentionsCount.inc
      signal.chats.add(chat)

  if event["event"]{"statusUpdates"} != nil:
    for jsonStatusUpdate in event["event"]["statusUpdates"]:
      var statusUpdate = jsonStatusUpdate.toStatusUpdate
      signal.statusUpdates.add(statusUpdate) 

  if event["event"]{"installations"} != nil:
    for jsonInstallation in event["event"]["installations"]:
      signal.installations.add(jsonInstallation.toInstallation)

  if event["event"]{"emojiReactions"} != nil:
    for jsonReaction in event["event"]["emojiReactions"]:
      signal.emojiReactions.add(jsonReaction.toReaction)

  if event["event"]{"communities"} != nil:
    for jsonCommunity in event["event"]["communities"]:
      signal.communities.add(jsonCommunity.toCommunity)

  if event["event"]{"requestsToJoinCommunity"} != nil:
    for jsonCommunity in event["event"]["requestsToJoinCommunity"]:
      signal.membershipRequests.add(jsonCommunity.toCommunityMembershipRequest)

  if event["event"]{"removedMessages"} != nil:
    for jsonRemovedMessage in event["event"]["removedMessages"]:
      signal.deletedMessages.add(jsonRemovedMessage.toRemovedMessage)

  if event["event"]{"activityCenterNotifications"} != nil:
    for jsonNotification in event["event"]["activityCenterNotifications"]:
      signal.activityCenterNotification.add(jsonNotification.toActivityCenterNotification())

  if event["event"]{"pinMessages"} != nil:
    for jsonPinnedMessage in event["event"]["pinMessages"]:
      var contentType: ContentType
      try:
        contentType = ContentType(jsonPinnedMessage{"contentType"}.getInt)
      except:
        contentType = ContentType.Message
      signal.pinnedMessages.add(Message(
        id: jsonPinnedMessage{"message_id"}.getStr,
        chatId: jsonPinnedMessage{"chat_id"}.getStr,
        localChatId: jsonPinnedMessage{"localChatId"}.getStr,
        pinnedBy: jsonPinnedMessage{"from"}.getStr,
        identicon: jsonPinnedMessage{"identicon"}.getStr,
        alias: jsonPinnedMessage{"alias"}.getStr,
        clock: jsonPinnedMessage{"clock"}.getInt,
        isPinned: jsonPinnedMessage{"pinned"}.getBool,
        contentType: contentType
      ))

  result = signal

