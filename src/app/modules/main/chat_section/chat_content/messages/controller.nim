import chronicles
import io_interface
import json

import ../../../../../../app/global/global_singleton
import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/message/service as message_service
import ../../../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../global/app_signals
import ../../../../../core/signals/types
import ../../../../../core/eventemitter
import ../../../../../core/unique_event_emitter

logScope:
  topics = "messages-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: UniqueUUIDEventEmitter
    sectionId: string
    chatId: string
    belongsToCommunity: bool
    searchedMessageId: string
    loadingMessagesPerPageFactor: int
    contactService: contact_service.Service
    communityService: community_service.Service
    chatService: chat_service.Service
    messageService: message_service.Service
    mailserversService: mailservers_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, contactService: contact_service.Service, communityService: community_service.Service,
  chatService: chat_service.Service, messageService: message_service.Service, mailserversService: mailservers_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = initUniqueUUIDEventEmitter(events)
  result.sectionId = sectionId
  result.chatId = chatId
  result.loadingMessagesPerPageFactor = 1
  result.belongsToCommunity = belongsToCommunity
  result.contactService = contactService
  result.communityService = communityService
  result.chatService = chatService
  result.messageService = messageService
  result.mailserversService = mailserversService

proc delete*(self: Controller) =
  self.events.disconnect()

proc init*(self: Controller) =
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.newMessagesLoaded(args.messages, args.reactions)

  self.events.on(SIGNAL_PINNED_MESSAGES_LOADED) do(e:Args):
    let args = PinnedMessagesLoadedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.newPinnedMessagesLoaded(args.pinnedMessages)

  self.events.on(SIGNAL_NEW_MESSAGE_RECEIVED) do(e: Args):
    var args = MessagesArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.messagesAdded(args.messages)

  self.events.on(SIGNAL_SENDING_SUCCESS) do(e:Args):
    let args = MessageSendingSuccess(e)
    if(self.chatId != args.chat.id):
      return
    self.delegate.onSendingMessageSuccess(args.message)

  self.events.on(SIGNAL_SENDING_FAILED) do(e:Args):
    let args = ChatArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onSendingMessageError()

  self.events.on(SIGNAL_ENVELOPE_SENT) do(e:Args):
    let args = EnvelopeSentArgs(e)
    self.delegate.onEnvelopeSent(args.messagesIds)

  self.events.on(SIGNAL_ENVELOPE_EXPIRED) do(e:Args):
    let args = EnvelopeExpiredArgs(e)
    self.delegate.onEnvelopeExpired(args.messagesIds)

  self.events.on(SIGNAL_MESSAGE_DELIVERED) do(e:Args):
    let args = MessageDeliveredArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onMessageDelivered(args.messageId)

  self.events.on(SIGNAL_MESSAGE_PINNED) do(e:Args):
    let args = MessagePinUnpinArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onPinMessage(args.messageId, args.actionInitiatedBy)

  self.events.on(SIGNAL_MESSAGE_UNPINNED) do(e:Args):
    let args = MessagePinUnpinArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onUnpinMessage(args.messageId)

  self.events.on(SIGNAL_MESSAGE_REACTION_ADDED) do(e:Args):
    let args = MessageAddRemoveReactionArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onReactionAdded(args.messageId, args.emojiId, args.reactionId)

  self.events.on(SIGNAL_MESSAGE_REACTION_REMOVED) do(e:Args):
    let args = MessageAddRemoveReactionArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onReactionRemoved(args.messageId, args.emojiId, args.reactionId)

  self.events.on(SIGNAL_MESSAGE_REACTION_FROM_OTHERS) do(e:Args):
    let args = MessageAddRemoveReactionArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.toggleReactionFromOthers(args.messageId, args.emojiId, args.reactionId, args.reactionFrom)

  self.events.on(SIGNAL_MESSAGES_MARKED_AS_READ) do(e: Args):
    let args = MessagesMarkedAsReadArgs(e)
    if(self.chatId != args.chatId):
      return
    if(args.allMessagesMarked):
      self.delegate.markAllMessagesRead()
    else:
      self.delegate.markMessagesAsRead(args.messagesIds)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNTRUSTWORTHY) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.updateContactDetails(args.publicKey)

  self.events.on(SIGNAL_CONTACT_TRUSTED) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.updateContactDetails(args.publicKey)

  self.events.on(SIGNAL_REMOVED_TRUST_STATUS) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.updateContactDetails(args.publicKey)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

  self.events.on(SIGNAL_LOGGEDIN_USER_NAME_CHANGED) do(e: Args):
    self.delegate.updateContactDetails(singletonInstance.userProfile.getPubKey())

  self.events.on(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED) do(e: Args):
    self.delegate.updateContactDetails(singletonInstance.userProfile.getPubKey())

  self.events.on(SIGNAL_MESSAGE_DELETION) do(e: Args):
    let args = MessageDeletedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onMessageDeleted(args.messageId)

  self.events.on(SIGNAL_MESSAGE_EDITED) do(e: Args):
    let args = MessageEditedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onMessageEdited(args.message)

  self.events.on(SIGNAL_CHAT_HISTORY_CLEARED) do (e: Args):
    var args = ChatArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onHistoryCleared()

  self.events.on(SIGNAL_MESSAGE_LINK_PREVIEW_DATA_LOADED) do(e: Args):
    let args = LinkPreviewDataArgs(e)
    self.delegate.onPreviewDataLoaded($(args.response), args.uuid)

  self.events.on(SIGNAL_MAKE_SECTION_CHAT_ACTIVE) do(e: Args):
    let args = ActiveSectionChatArgs(e)
    if(self.sectionId != args.sectionId or self.chatId != args.chatId):
      return
    self.delegate.scrollToMessage(args.messageId)

  self.events.on(SIGNAL_CHAT_MEMBER_UPDATED) do(e: Args):
    let args = ChatMemberUpdatedArgs(e)
    if (args.chatId != self.chatId):
      return
    self.delegate.onChatMemberUpdated(args.id, args.admin, args.joined)

  self.events.on(SIGNAL_MAILSERVER_SYNCED) do(e: Args):
    let args = MailserverSyncedArgs(e)
    if (args.chatId != self.chatId):
      return
    self.delegate.onMailserverSynced(args.syncedFrom)

  self.events.on(SIGNAL_COMMUNITIES_UPDATE) do(e: Args):
    let args = CommunitiesArgs(e)
    for community in args.communities:
      if (community.id == self.sectionId):
        self.delegate.updateCommunityDetails(community)

  self.events.on(SIGNAL_FIRST_UNSEEN_MESSAGE_LOADED) do(e: Args):
    let args = FirstUnseenMessageLoadedArgs(e)
    if (args.chatId != self.chatId):
      return
    self.delegate.onFirstUnseenMessageLoaded(args.messageId)

proc getMySectionId*(self: Controller): string =
  return self.sectionId

proc getMyChatId*(self: Controller): string =
  return self.chatId

proc getChatDetails*(self: Controller): ChatDto =
  return self.chatService.getChatById(self.chatId)

proc getCommunityDetails*(self: Controller): CommunityDto =
  return self.communityService.getCommunityById(self.sectionId)

proc getCommunityById*(self: Controller, communityId: string): CommunityDto =
  return self.communityService.getCommunityById(communityId)

proc getOneToOneChatNameAndImage*(self: Controller):
    tuple[name: string, image: string, largeImage: string] =
  return self.chatService.getOneToOneChatNameAndImage(self.chatId)

proc belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity

proc loadMoreMessages*(self: Controller) =
  let limit = self.loadingMessagesPerPageFactor * MESSAGES_PER_PAGE
  self.messageService.asyncLoadMoreMessagesForChat(self.chatId, limit)

proc addReaction*(self: Controller, messageId: string, emojiId: int) =
  self.messageService.addReaction(self.chatId, messageId, emojiId)

proc removeReaction*(self: Controller, messageId: string, emojiId: int, reactionId: string) =
  self.messageService.removeReaction(reactionId, self.chatId, messageId, emojiId)

proc pinUnpinMessage*(self: Controller, messageId: string, pin: bool) =
  self.messageService.pinUnpinMessage(self.chatId, messageId, pin)

proc getContactById*(self: Controller, contactId: string): ContactsDto =
  return self.contactService.getContactById(contactId)

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactService.getContactDetails(contactId)

proc getNumOfPinnedMessages*(self: Controller): int =
  return self.messageService.getNumOfPinnedMessages(self.chatId)

proc getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText], communityChats: seq[ChatDto]): string =
  return self.messageService.getRenderedText(parsedTextArray, communityChats)

proc deleteMessage*(self: Controller, messageId: string) =
  self.messageService.deleteMessage(messageId)

proc editMessage*(self: Controller, messageId: string, contentType: int, updatedMsg: string) =
  self.messageService.editMessage(messageId, contentType, updatedMsg)

proc getLinkPreviewData*(self: Controller, link: string, uuid: string, whiteListedSites: string, whiteListedImgExtensions: string, unfurlImages: bool): string =
  self.messageService.asyncGetLinkPreviewData(link, uuid, whiteListedSites, whiteListedImgExtensions, unfurlImages)

proc getSearchedMessageId*(self: Controller): string =
  return self.searchedMessageId

proc setSearchedMessageId*(self: Controller, searchedMessageId: string) =
  self.searchedMessageId = searchedMessageId

proc clearSearchedMessageId*(self: Controller) =
  self.setSearchedMessageId("")

proc getAsyncFirstUnseenMessageId*(self: Controller) =
  self.messageService.getAsyncFirstUnseenMessageId(self.chatId)

proc getLoadingMessagesPerPageFactor*(self: Controller): int =
  return self.loadingMessagesPerPageFactor

proc increaseLoadingMessagesPerPageFactor*(self: Controller) =
  self.loadingMessagesPerPageFactor = self.loadingMessagesPerPageFactor + 1

proc resetLoadingMessagesPerPageFactor*(self: Controller) =
  self.loadingMessagesPerPageFactor = 1

proc requestMoreMessages*(self: Controller) =
  self.mailserversService.requestMoreMessages(self.chatId)

proc fillGaps*(self: Controller, messageId: string) =
  self.mailserversService.fillGaps(self.chatId, messageId)

proc getTransactionDetails*(self: Controller, message: MessageDto): (string,string) =
  return self.messageService.getTransactionDetails(message)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.messageService.getWalletAccounts()

proc leaveChat*(self: Controller) =
  self.chatService.leaveChat(self.chatId)

proc resendChatMessage*(self: Controller, messageId: string): string =
  return self.messageService.resendChatMessage(messageId)
