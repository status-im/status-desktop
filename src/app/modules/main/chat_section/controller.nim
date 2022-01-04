import Tables

import controller_interface
import io_interface

import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service

import eventemitter

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    sectionId: string
    isCommunitySection: bool
    activeItemId: string
    activeSubItemId: string
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, sectionId: string, isCommunity: bool, events: EventEmitter,
  settingsService: settings_service.ServiceInterface, contactService: contact_service.Service, 
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.sectionId = sectionId
  result.isCommunitySection = isCommunity
  result.events = events
  result.settingsService = settingsService
  result.contactService = contactService
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(chat_service.SIGNAL_CHAT_MUTED) do(e:Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onChatMuted(args.chatId)

  self.events.on(chat_service.SIGNAL_CHAT_UNMUTED) do(e:Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onChatUnmuted(args.chatId)

  self.events.on(message_service.SIGNAL_MESSAGES_MARKED_AS_READ) do(e: Args):
    let args = message_service.MessagesMarkedAsReadArgs(e)
    self.delegate.onMarkAllMessagesRead(args.chatId)

  self.events.on(chat_service.SIGNAL_CHAT_LEFT) do(e: Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.removeChat(args.chatId)

  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactAccepted(args.contactId)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactRejected(args.contactId)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactBlocked(args.contactId)

method getMySectionId*(self: Controller): string =
  return self.sectionId

method getActiveChatId*(self: Controller): string =
  if(self.activeSubItemId.len > 0):
    return self.activeSubItemId
  else:
    return self.activeItemId

method isCommunity*(self: Controller): bool =
  return self.isCommunitySection

method getJoinedCommunities*(self: Controller): seq[CommunityDto] =
  return self.communityService.getJoinedCommunities()

method getCategories*(self: Controller, communityId: string): seq[Category] =
  return self.communityService.getCategories(communityId)

method getChats*(self: Controller, communityId: string, categoryId: string): seq[Chat] =
  return self.communityService.getChats(communityId, categoryId)

method getChatDetails*(self: Controller, communityId, chatId: string): ChatDto =
  let fullId = communityId & chatId
  return self.chatService.getChatById(fullId)

method getChatDetailsForChatTypes*(self: Controller, types: seq[ChatType]): seq[ChatDto] =
  return self.chatService.getChatsOfChatTypes(types)

method setActiveItemSubItem*(self: Controller, itemId: string, subItemId: string) =
  self.activeItemId = itemId
  self.activeSubItemId = subItemId

  self.messageService.asyncLoadInitialMessagesForChat(self.getActiveChatId())

  # We need to take other actions here like notify status go that unviewed mentions count is updated and so...

  self.delegate.activeItemSubItemSet(self.activeItemId, self.activeSubItemId)

method removeActiveFromThisChat*(self: Controller, itemId: string) =
  if self.activeItemId != itemId:
    return

  let allChats = self.chatService.getAllChats()

  self.activeSubItemId = ""
  if allChats.len == 0:
    self.activeItemId = ""
  else:
    self.activeItemId = allChats[0].id

  self.delegate.activeItemSubItemSet(self.activeItemId, self.activeSubItemId)

method getOneToOneChatNameAndImage*(self: Controller, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

method createPublicChat*(self: Controller, chatId: string) =
  let response = self.chatService.createPublicChat(chatId)
  if(response.success):
    self.delegate.addNewChat(response.chatDto, self.events, self.settingsService, self.contactService, self.chatService,
    self.communityService, self.messageService)

method createOneToOneChat*(self: Controller, chatId: string, ensName: string) =
  let response = self.chatService.createOneToOneChat(chatId, ensName)
  if(response.success):
    self.delegate.addNewChat(response.chatDto, self.events, self.settingsService, self.contactService, self.chatService,
    self.communityService, self.messageService)

method leaveChat*(self: Controller, chatId: string) =
  self.chatService.leaveChat(chatId)

method muteChat*(self: Controller, chatId: string) =
  self.chatService.muteChat(chatId)

method unmuteChat*(self: Controller, chatId: string) =
  self.chatService.unmuteChat(chatId)

method markAllMessagesRead*(self: Controller, chatId: string) =
  self.messageService.markAllMessagesRead(chatId)

method clearChatHistory*(self: Controller, chatId: string) =
  self.chatService.clearChatHistory(chatId)

method getCurrentFleet*(self: Controller): string =
  return self.settingsService.getFleetAsString()

method getContacts*(self: Controller): seq[ContactsDto] =
  return self.contactService.getContacts()

method getContact*(self: Controller, id: string): ContactsDto =
  return self.contactService.getContactById(id)

method getContactNameAndImage*(self: Controller, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactService.getContactNameAndImage(contactId)

method addContact*(self: Controller, publicKey: string) =
  self.contactService.addContact(publicKey)

method rejectContactRequest*(self: Controller, publicKey: string) =
  self.contactService.rejectContactRequest(publicKey)

method blockContact*(self: Controller, publicKey: string) =
  self.contactService.blockContact(publicKey)