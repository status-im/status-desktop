import json, chronicles

import base

import ../../../../app_service/service/message/dto/[message, pinned_message_update, reaction, removed_message]
import ../../../../app_service/service/chat/dto/[chat]
import ../../../../app_service/service/bookmarks/dto/[bookmark]
import ../../../../app_service/service/community/dto/[community]
import ../../../../app_service/service/activity_center/dto/[notification]
import ../../../../app_service/service/contacts/dto/[contacts, status_update]
import ../../../../app_service/service/devices/dto/[installation]
import ../../../../app_service/service/settings/dto/[settings]
import ../../../../app_service/service/saved_address/dto as saved_address_dto
import ../../../../app_service/service/wallet_account/[keypair_dto, keycard_dto]

type MessageSignal* = ref object of Signal
  bookmarks*: seq[BookmarkDto]
  messages*: seq[MessageDto]
  pinnedMessages*: seq[PinnedMessageUpdateDto]
  chats*: seq[ChatDto]
  contacts*: seq[ContactsDto]
  installations*: seq[InstallationDto]
  emojiReactions*: seq[ReactionDto]
  communities*: seq[CommunityDto]
  communitiesSettings*: seq[CommunitySettingsDto]
  membershipRequests*: seq[CommunityMembershipRequestDto]
  activityCenterNotifications*: seq[ActivityCenterNotificationDto]
  statusUpdates*: seq[StatusUpdateDto]
  deletedMessages*: seq[RemovedMessageDto]
  removedChats*: seq[string]
  currentStatus*: seq[StatusUpdateDto]
  settings*: seq[SettingsFieldDto]
  clearedHistories*: seq[ClearedHistoryDto]
  verificationRequests*: seq[VerificationRequest]
  savedAddresses*: seq[SavedAddressDto]
  keypairs*: seq[KeypairDto]
  keycards*: seq[KeycardDto]
  keycardActions*: seq[KeycardActionDto]
  walletAccounts*: seq[WalletAccountDto]

type MessageDeliveredSignal* = ref object of Signal
  chatId*: string
  messageId*: string

proc fromEvent*(T: type MessageDeliveredSignal, event: JsonNode): MessageDeliveredSignal =
  result = MessageDeliveredSignal()
  result.signalType = SignalType.MessageDelivered
  result.chatId = event["event"]["chatID"].getStr
  result.messageId = event["event"]["messageID"].getStr

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
      info "received", signal="messages.new", messageID=message.id

  if event["event"]{"chats"} != nil:
    for jsonChat in event["event"]["chats"]:
      var chat = jsonChat.toChatDto()
      signal.chats.add(chat)

  if event["event"]{"clearedHistories"} != nil:
    for jsonClearedHistory in event["event"]{"clearedHistories"}:
      var clearedHistoryDto = jsonClearedHistory.toClearedHistoryDto()
      signal.clearedHistories.add(clearedHistoryDto)

  if event["event"]{"statusUpdates"} != nil:
    for jsonStatusUpdate in event["event"]["statusUpdates"]:
      var statusUpdate = jsonStatusUpdate.toStatusUpdateDto()
      signal.statusUpdates.add(statusUpdate)

  if event["event"]{"currentStatus"} != nil:
      var currentStatus = event["event"]["currentStatus"].toStatusUpdateDto()
      signal.currentStatus.add(currentStatus)

  if event["event"]{"bookmarks"} != nil:
    for jsonBookmark in event["event"]["bookmarks"]:
      var bookmark = jsonBookmark.toBookmarkDto()
      signal.bookmarks.add(bookmark)

  if event["event"]{"installations"} != nil:
    for jsonDevice in event["event"]["installations"]:
      signal.installations.add(jsonDevice.toInstallationDto())

  if event["event"]{"emojiReactions"} != nil:
    for jsonReaction in event["event"]["emojiReactions"]:
      signal.emojiReactions.add(jsonReaction.toReactionDto())

  if event["event"]{"communities"} != nil:
    for jsonCommunity in event["event"]["communities"]:
      signal.communities.add(jsonCommunity.toCommunityDto())

  if event["event"]{"communitiesSettings"} != nil:
    for jsonCommunitySettings in event["event"]["communitiesSettings"]:
      signal.communitiesSettings.add(jsonCommunitySettings.toCommunitySettingsDto())

  if event["event"]{"requestsToJoinCommunity"} != nil:
    for jsonCommunity in event["event"]["requestsToJoinCommunity"]:
      signal.membershipRequests.add(jsonCommunity.toCommunityMembershipRequestDto())

  if event["event"]{"removedMessages"} != nil:
    for jsonRemovedMessage in event["event"]["removedMessages"]:
      signal.deletedMessages.add(jsonRemovedMessage.toRemovedMessageDto())

  if event["event"]{"removedChats"} != nil:
    for removedChatID in event["event"]["removedChats"]:
      signal.removedChats.add(removedChatID.getStr())

  if event["event"]{"activityCenterNotifications"} != nil:
    for jsonNotification in event["event"]["activityCenterNotifications"]:
      signal.activityCenterNotifications.add(jsonNotification.toActivityCenterNotificationDto())

  if event["event"]{"pinMessages"} != nil:
    for jsonPinnedMessage in event["event"]["pinMessages"]:
      signal.pinnedMessages.add(jsonPinnedMessage.toPinnedMessageUpdateDto())

  if event["event"]{"settings"} != nil:
    for jsonSettingsField in event["event"]["settings"]:
      signal.settings.add(jsonSettingsField.toSettingsFieldDto())

  if event["event"]{"verificationRequests"} != nil:
    for jsonVerificationRequest in event["event"]["verificationRequests"]:
      signal.verificationRequests.add(jsonVerificationRequest.toVerificationRequest())

  if event["event"]{"savedAddresses"} != nil:
    for jsonSavedAddress in event["event"]["savedAddresses"]:
      signal.savedAddresses.add(jsonSavedAddress.toSavedAddressDto())

  if event["event"]{"keypairs"} != nil:
    for jsonKc in event["event"]["keypairs"]:
      signal.keypairs.add(jsonKc.toKeypairDto())

  if event["event"]{"keycards"} != nil:
    for jsonKc in event["event"]["keycards"]:
      signal.keycards.add(jsonKc.toKeycardDto())

  if event["event"]{"keycardActions"} != nil:
    for jsonKc in event["event"]["keycardActions"]:
      signal.keycardActions.add(jsonKc.toKeycardActionDto())

  if event["event"]{"accounts"} != nil:
    for jsonAcc in event["event"]["accounts"]:
      signal.walletAccounts.add(jsonAcc.toWalletAccountDto())

  result = signal

