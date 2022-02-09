import chronicles
import controller_interface
import io_interface

import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/message/service as message_service
import ../../../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../../../app_service/service/eth/utils as eth_utils
import ../../../../../core/signals/types
import ../../../../../core/eventemitter

export controller_interface

logScope:
  topics = "messages-controller"

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
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
  result.events = events
  result.sectionId = sectionId
  result.chatId = chatId
  result.loadingMessagesPerPageFactor = 1
  result.belongsToCommunity = belongsToCommunity
  result.contactService = contactService
  result.communityService = communityService
  result.chatService = chatService
  result.messageService = messageService
  result.mailserversService = mailserversService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.newMessagesLoaded(args.messages, args.reactions, args.pinnedMessages)

  self.events.on(SIGNAL_NEW_MESSAGE_RECEIVED) do(e: Args):
    var args = MessagesArgs(e)
    if(self.chatId != args.chatId):
      return
    for message in args.messages:
      self.delegate.messageAdded(message)

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

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.updateContactDetails(args.contactId)

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

  self.events.on(SignalType.HistoryRequestStarted.event) do(e: Args):
    self.delegate.setLoadingHistoryMessagesInProgress(true)

  self.events.on(SignalType.HistoryRequestCompleted.event) do(e:Args):
    self.delegate.setLoadingHistoryMessagesInProgress(false)

  self.events.on(SignalType.HistoryRequestFailed.event) do(e:Args):
    self.delegate.setLoadingHistoryMessagesInProgress(false)

  self.events.on(SIGNAL_MESSAGE_LINK_PREVIEW_DATA_LOADED) do(e: Args):
    let args = LinkPreviewDataArgs(e)
    self.delegate.onPreviewDataLoaded(args.response)

  self.events.on(SIGNAL_MAKE_SECTION_CHAT_ACTIVE) do(e: Args):
    var args = ActiveSectionChatArgs(e)
    if(self.sectionId != args.sectionId or self.chatId != args.chatId):
      return
    self.delegate.scrollToMessage(args.messageId)

method getMySectionId*(self: Controller): string =
  return self.sectionId

method getMyChatId*(self: Controller): string =
  return self.chatId

method getChatDetails*(self: Controller): ChatDto =
  return self.chatService.getChatById(self.chatId)

method getCommunityDetails*(self: Controller): CommunityDto =
  return self.communityService.getCommunityById(self.sectionId)

method getOneToOneChatNameAndImage*(self: Controller): tuple[name: string, image: string, isIdenticon: bool] =
  return self.chatService.getOneToOneChatNameAndImage(self.chatId)

method belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity

method loadMoreMessages*(self: Controller) =
  let limit = self.loadingMessagesPerPageFactor * MESSAGES_PER_PAGE
  self.messageService.asyncLoadMoreMessagesForChat(self.chatId, limit)

method addReaction*(self: Controller, messageId: string, emojiId: int) =
  self.messageService.addReaction(self.chatId, messageId, emojiId)

method removeReaction*(self: Controller, messageId: string, emojiId: int, reactionId: string) =
  self.messageService.removeReaction(reactionId, self.chatId, messageId, emojiId)

method pinUnpinMessage*(self: Controller, messageId: string, pin: bool) =
  self.messageService.pinUnpinMessage(self.chatId, messageId, pin)

method getContactById*(self: Controller, contactId: string): ContactsDto =
  return self.contactService.getContactById(contactId)

method getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactService.getContactDetails(contactId)

method getNumOfPinnedMessages*(self: Controller): int =
  return self.messageService.getNumOfPinnedMessages(self.chatId)

method getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText]): string =
  return self.messageService.getRenderedText(parsedTextArray)

method getMessageDetails*(self: Controller, messageId: string):
  tuple[message: MessageDto, reactions: seq[ReactionDto], error: string] =
  return self.messageService.getDetailsForMessage(self.chatId, messageId)

method deleteMessage*(self: Controller, messageId: string) =
  self.messageService.deleteMessage(messageId)

method decodeContentHash*(self: Controller, hash: string): string =
  return eth_utils.decodeContentHash(hash)

method editMessage*(self: Controller, messageId: string, updatedMsg: string) =
  self.messageService.editMessage(messageId, updatedMsg)

method getLinkPreviewData*(self: Controller, link: string, uuid: string): string =
  self.messageService.asyncGetLinkPreviewData(link, uuid)

method getSearchedMessageId*(self: Controller): string =
  return self.searchedMessageId

method setSearchedMessageId*(self: Controller, searchedMessageId: string) =
  self.searchedMessageId = searchedMessageId

method clearSearchedMessageId*(self: Controller) =
  self.setSearchedMessageId("")

method getLoadingMessagesPerPageFactor*(self: Controller): int =
  return self.loadingMessagesPerPageFactor

method increaseLoadingMessagesPerPageFactor*(self: Controller) =
  self.loadingMessagesPerPageFactor = self.loadingMessagesPerPageFactor + 1

method resetLoadingMessagesPerPageFactor*(self: Controller) =
  self.loadingMessagesPerPageFactor = 1

method requestMoreMessages*(self: Controller) =
  self.mailserversService.requestMoreMessages(self.chatId)

method fillGaps*(self: Controller, messageId: string) =
  self.mailserversService.fillGaps(self.chatId, messageId)
