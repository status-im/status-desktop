import Tables

import controller_interface
import io_interface

import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service

import ../../../../core/signals/types
import eventemitter

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    chatId: string
    belongsToCommunity: bool
    isUsersListAvailable: bool #users list is not available for 1:1 chat
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, chatId: string, 
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.isUsersListAvailable = isUsersListAvailable
  result.contactService = contactService
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.newPinnedMessagesLoaded(args.pinnedMessages)

  self.events.on(SIGNAL_MESSAGE_PINNED) do(e:Args):
    let args = MessagePinUnpinArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onPinMessage(args.messageId)

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

method getMyChatId*(self: Controller): string =
  return self.chatId

method getChatDetails*(self: Controller): ChatDto =
  return self.chatService.getChatById(self.chatId)

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

method unmuteChat*(self: Controller) =
  self.chatService.unmuteChat(self.chatId)

method getContactById*(self: Controller, contactId: string): ContactsDto =
  return self.contactService.getContactById(contactId)

method getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactService.getContactDetails(contactId)