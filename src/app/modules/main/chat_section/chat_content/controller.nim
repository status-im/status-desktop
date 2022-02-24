import Tables

import controller_interface
import io_interface

import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service
import ../../../../../app_service/service/eth/utils as eth_utils
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ../../../../core/signals/types
import ../../../../core/eventemitter

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    sectionId: string
    chatId: string
    belongsToCommunity: bool
    isUsersListAvailable: bool #users list is not available for 1:1 chat
    settingsService: settings_service.ServiceInterface
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, isUsersListAvailable: bool, settingsService: settings_service.ServiceInterface,
  contactService: contact_service.Service, chatService: chat_service.Service,
  communityService: community_service.Service, messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.sectionId = sectionId
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.isUsersListAvailable = isUsersListAvailable
  result.settingsService = settingsService
  result.contactService = contactService
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    if(self.chatId != args.chatId or args.pinnedMessages.len == 0):
      return
    self.delegate.newPinnedMessagesLoaded(args.pinnedMessages)

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

  self.events.on(SIGNAL_CHAT_MUTED) do(e:Args):
    let args = ChatArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onChatMuted()

  self.events.on(SIGNAL_CHAT_UNMUTED) do(e:Args):
    let args = ChatArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onChatUnmuted()

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
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_MESSAGE_DELETION) do(e: Args):
    let args = MessageDeletedArgs(e)
    if(self.chatId != args.chatId):
      return
    # remove from pinned messages model
    self.delegate.onUnpinMessage(args.messageId)

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_EDITED) do(e:Args):
    let args = CommunityChatArgs(e)
    if(args.chat.communityId != self.sectionId or args.chat.id != self.chatId):
      return
    self.delegate.onChatEdited(args.chat)

  self.events.on(SIGNAL_CHAT_RENAMED) do(e: Args):
    var args = ChatRenameArgs(e)
    if(self.chatId != args.id):
      return
    self.delegate.onChatRenamed(args.newName)

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

method unpinMessage*(self: Controller, messageId: string) =
  self.messageService.pinUnpinMessage(self.chatId, messageId, false)

method getMessageDetails*(self: Controller, messageId: string):
  tuple[message: MessageDto, reactions: seq[ReactionDto], error: string] =
  return self.messageService.getDetailsForMessage(self.chatId, messageId)

method isUsersListAvailable*(self: Controller): bool =
  return self.isUsersListAvailable

method getMyAddedContacts*(self: Controller): seq[ContactsDto] =
  return self.contactService.getAddedContacts()

method muteChat*(self: Controller) =
  self.chatService.muteChat(self.chatId)

method unmuteChat*(self: Controller) =
  self.chatService.unmuteChat(self.chatId)

method unblockChat*(self: Controller) =
  self.contactService.unblockContact(self.chatId)

method markAllMessagesRead*(self: Controller) =
  self.messageService.markAllMessagesRead(self.chatId)

method clearChatHistory*(self: Controller) =
  self.chatService.clearChatHistory(self.chatId)

method leaveChat*(self: Controller) =
  self.chatService.leaveChat(self.chatId)

method getContactById*(self: Controller, contactId: string): ContactsDto =
  return self.contactService.getContactById(contactId)

method getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactService.getContactDetails(contactId)

method getCurrentFleet*(self: Controller): string =
  return self.settingsService.getFleetAsString()

method getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText]): string =
  return self.messageService.getRenderedText(parsedTextArray)

method decodeContentHash*(self: Controller, hash: string): string =
  return eth_utils.decodeContentHash(hash)

method getTransactionDetails*(self: Controller, message: MessageDto): (string,string) =
  return self.messageService.getTransactionDetails(message)

method getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.messageService.getWalletAccounts()