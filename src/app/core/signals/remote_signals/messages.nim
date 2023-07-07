import json, chronicles

import base

import ../../../../app_service/common/social_links
import ../../../../app_service/service/message/dto/[message, pinned_message_update, reaction, removed_message]
import ../../../../app_service/service/chat/dto/[chat]
import ../../../../app_service/service/bookmarks/dto/[bookmark]
import ../../../../app_service/service/community/dto/[community]
import ../../../../app_service/service/activity_center/dto/[notification]
import ../../../../app_service/service/contacts/dto/[contacts, status_update]
import ../../../../app_service/service/devices/dto/[installation]
import ../../../../app_service/service/settings/dto/[settings]
import ../../../../app_service/service/saved_address/dto as saved_address_dto
import ../../../../app_service/service/wallet_account/[keypair_dto]

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
  socialLinksInfo*: SocialLinksInfo
  clearedHistories*: seq[ClearedHistoryDto]
  verificationRequests*: seq[VerificationRequest]
  savedAddresses*: seq[SavedAddressDto]
  keypairs*: seq[KeypairDto]
  watchOnlyAccounts*: seq[WalletAccountDto]

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

  if not event.contains("event"):
    return signal

  let e = event["event"]

  if e.contains("contacts"):
    for jsonContact in e["contacts"]:
      signal.contacts.add(jsonContact.toContactsDto())

  if e.contains("messages"):
    for jsonMsg in e["messages"]:
      var message = jsonMsg.toMessageDto()
      signal.messages.add(message)
      info "received", signal="messages.new", messageID=message.id

  if e.contains("chats"):
    for jsonChat in e["chats"]:
      var chat = jsonChat.toChatDto()
      signal.chats.add(chat)

  if e.contains("clearedHistories"):
    for jsonClearedHistory in e["clearedHistories"]:
      var clearedHistoryDto = jsonClearedHistory.toClearedHistoryDto()
      signal.clearedHistories.add(clearedHistoryDto)

  if e.contains("statusUpdates"):
    for jsonStatusUpdate in e["statusUpdates"]:
      var statusUpdate = jsonStatusUpdate.toStatusUpdateDto()
      signal.statusUpdates.add(statusUpdate)

  if e.contains("currentStatus"):
      var currentStatus = e["currentStatus"].toStatusUpdateDto()
      signal.currentStatus.add(currentStatus)

  if e.contains("bookmarks"):
    for jsonBookmark in e["bookmarks"]:
      var bookmark = jsonBookmark.toBookmarkDto()
      signal.bookmarks.add(bookmark)

  if e.contains("installations"):
    for jsonDevice in e["installations"]:
      signal.installations.add(jsonDevice.toInstallationDto())

  if e.contains("emojiReactions"):
    for jsonReaction in e["emojiReactions"]:
      signal.emojiReactions.add(jsonReaction.toReactionDto())

  if e.contains("communities"):
    for jsonCommunity in e["communities"]:
      signal.communities.add(jsonCommunity.toCommunityDto())

  if e.contains("communitiesSettings"):
    for jsonCommunitySettings in e["communitiesSettings"]:
      signal.communitiesSettings.add(jsonCommunitySettings.toCommunitySettingsDto())

  if e.contains("requestsToJoinCommunity"):
    for jsonCommunity in e["requestsToJoinCommunity"]:
      signal.membershipRequests.add(jsonCommunity.toCommunityMembershipRequestDto())

  if e.contains("removedMessages"):
    for jsonRemovedMessage in e["removedMessages"]:
      signal.deletedMessages.add(jsonRemovedMessage.toRemovedMessageDto())

  if e.contains("removedChats"):
    for removedChatID in e["removedChats"]:
      signal.removedChats.add(removedChatID.getStr())

  if e.contains("activityCenterNotifications"):
    for jsonNotification in e["activityCenterNotifications"]:
      signal.activityCenterNotifications.add(jsonNotification.toActivityCenterNotificationDto())

  if e.contains("pinMessages"):
    for jsonPinnedMessage in e["pinMessages"]:
      signal.pinnedMessages.add(jsonPinnedMessage.toPinnedMessageUpdateDto())

  if e.contains("settings"):
    for jsonSettingsField in e["settings"]:
      signal.settings.add(jsonSettingsField.toSettingsFieldDto())

  if e.contains("socialLinksInfo"):
    signal.socialLinksInfo = toSocialLinksInfo(e["socialLinksInfo"])

  if e.contains("verificationRequests"):
    for jsonVerificationRequest in e["verificationRequests"]:
      signal.verificationRequests.add(jsonVerificationRequest.toVerificationRequest())

  if e.contains("savedAddresses"):
    for jsonSavedAddress in e["savedAddresses"]:
      signal.savedAddresses.add(jsonSavedAddress.toSavedAddressDto())

  if e.contains("keypairs"):
    for jsonKc in e["keypairs"]:
      signal.keypairs.add(jsonKc.toKeypairDto())

  if e.contains("watchOnlyAccounts"):
    for jsonAcc in e["watchOnlyAccounts"]:
      signal.watchOnlyAccounts.add(jsonAcc.toWalletAccountDto())

  result = signal

