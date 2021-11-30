import json

import base

# Step by step we should remove all these types from `status-lib`
import status/types/[installation, activity_center_notification, removed_message]
import status/types/community as old_community

import ../../../../app_service/service/message/dto/[message, pinned_message, reaction]
import ../../../../app_service/service/chat/dto/[chat]
import ../../../../app_service/service/community/dto/[community]
import ../../../../app_service/service/contacts/dto/[contacts, status_update]

type MessageSignal* = ref object of Signal
  messages*: seq[MessageDto]
  pinnedMessages*: seq[PinnedMessageDto]
  chats*: seq[ChatDto]
  contacts*: seq[ContactsDto]
  installations*: seq[Installation]
  emojiReactions*: seq[ReactionDto]
  communities*: seq[CommunityDto]
  membershipRequests*: seq[old_community.CommunityMembershipRequest]
  activityCenterNotification*: seq[ActivityCenterNotification]
  statusUpdates*: seq[StatusUpdateDto]
  deletedMessages*: seq[RemovedMessage]

proc fromEvent*(T: type MessageSignal, event: JsonNode): MessageSignal = 
  var signal:MessageSignal = MessageSignal()
  signal.messages = @[]
  signal.contacts = @[]

  if event["event"]{"contacts"} != nil:
    for jsonContact in event["event"]["contacts"]:
      signal.contacts.add(jsonContact.toContactsDto())

  if event["event"]{"messages"} != nil:
    for jsonMsg in event["event"]["messages"]:
      var message = jsonMsg.toMessageDto()
      signal.messages.add(message)

  if event["event"]{"chats"} != nil:
    for jsonChat in event["event"]["chats"]:
      var chat = jsonChat.toChatDto()
      signal.chats.add(chat)

  if event["event"]{"statusUpdates"} != nil:
    for jsonStatusUpdate in event["event"]["statusUpdates"]:
      var statusUpdate = jsonStatusUpdate.toStatusUpdateDto()
      signal.statusUpdates.add(statusUpdate) 

  if event["event"]{"installations"} != nil:
    for jsonInstallation in event["event"]["installations"]:
      signal.installations.add(jsonInstallation.toInstallation)

  if event["event"]{"emojiReactions"} != nil:
    for jsonReaction in event["event"]["emojiReactions"]:
      signal.emojiReactions.add(jsonReaction.toReactionDto())

  if event["event"]{"communities"} != nil:
    for jsonCommunity in event["event"]["communities"]:
      signal.communities.add(jsonCommunity.toCommunityDto())

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
    discard
    # Need to refactor this
  #   for jsonPinnedMessage in event["event"]["pinMessages"]:
  #     var contentType: ContentType
  #     try:
  #       contentType = ContentType(jsonPinnedMessage{"contentType"}.getInt)
  #     except:
  #       contentType = ContentType.Message
  #     signal.pinnedMessages.add(Message(
  #       id: jsonPinnedMessage{"message_id"}.getStr,
  #       chatId: jsonPinnedMessage{"chat_id"}.getStr,
  #       localChatId: jsonPinnedMessage{"localChatId"}.getStr,
  #       pinnedBy: jsonPinnedMessage{"from"}.getStr,
  #       identicon: jsonPinnedMessage{"identicon"}.getStr,
  #       alias: jsonPinnedMessage{"alias"}.getStr,
  #       clock: jsonPinnedMessage{"clock"}.getInt,
  #       isPinned: jsonPinnedMessage{"pinned"}.getBool,
  #       contentType: contentType
  #     ))

  result = signal

