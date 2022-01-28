import Tables

import controller_interface
import io_interface

import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service

import ../../../core/eventemitter

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
    gifService: gif_service.Service

proc newController*(delegate: io_interface.AccessInterface, sectionId: string, isCommunity: bool, events: EventEmitter,
  settingsService: settings_service.ServiceInterface, contactService: contact_service.Service, 
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service, gifService: gif_service.Service): Controller =
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
  result.gifService = gifService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_NEW_MESSAGE_RECEIVED) do(e: Args):
    let args = MessagesArgs(e)
    if(self.isCommunitySection and args.chatType != ChatType.CommunityChat or
      not self.isCommunitySection and args.chatType == ChatType.CommunityChat):
        return
    self.delegate.onNewMessagesReceived(args.chatId, args.unviewedMessagesCount, args.unviewedMentionsCount, 
    args.messages)

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
    self.delegate.onCommunityChannelDeletedOrChatLeft(args.chatId)

  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactAccepted(args.contactId)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactRejected(args.contactId)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactBlocked(args.contactId)

  if (self.isCommunitySection):
    self.events.on(SIGNAL_COMMUNITY_CHANNEL_CREATED) do(e:Args):
      let args = CommunityChatArgs(e)
      if (args.chat.communityId == self.sectionId):
        self.delegate.addNewChat(
          args.chat,
          true,
          self.events,
          self.settingsService,
          self.contactService,
          self.chatService,
          self.communityService,
          self.messageService,
          self.gifService
        )

    self.events.on(SIGNAL_COMMUNITY_CHANNEL_DELETED) do(e:Args):
      let args = CommunityChatIdArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityChannelDeletedOrChatLeft(args.chatId)

    self.events.on(SIGNAL_COMMUNITY_CHANNEL_EDITED) do(e:Args):
      let args = CommunityChatArgs(e)
      if (args.chat.communityId == self.sectionId):
        self.delegate.onCommunityChannelEdited(args.chat)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_CREATED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityCategoryCreated(args.category, args.chats)

    self.events.on(SIGNAL_COMMUNITY_CHANNEL_REORDERED) do(e:Args):
      let args = CommunityChatOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.reorderChannels(args.chatId, args.categoryId, args.position)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CHAT_RENAMED) do(e: Args):
    var args = ChatRenameArgs(e)
    self.delegate.onChatRenamed(args.id, args.newName)

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

method getMyCommunity*(self: Controller): CommunityDto =
  return self.communityService.getCommunityById(self.sectionId)

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

method removeCommunityChat*(self: Controller, itemId: string) =
  self.communityService.deleteCommunityChat(self.getMySectionId(), itemId)

method getOneToOneChatNameAndImage*(self: Controller, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

method createPublicChat*(self: Controller, chatId: string) =
  let response = self.chatService.createPublicChat(chatId)
  if(response.success):
    self.delegate.addNewChat(response.chatDto, false, self.events, self.settingsService, self.contactService, self.chatService,
    self.communityService, self.messageService, self.gifService)

method createOneToOneChat*(self: Controller, chatId: string, ensName: string) =
  let response = self.chatService.createOneToOneChat(chatId, ensName)
  if(response.success):
    self.delegate.addNewChat(response.chatDto, false, self.events, self.settingsService, self.contactService, self.chatService,
    self.communityService, self.messageService, self.gifService)

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

method getContactDetails*(self: Controller, id: string): ContactDetails =
  return self.contactService.getContactDetails(id)

method getContactNameAndImage*(self: Controller, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactService.getContactNameAndImage(contactId)

method addContact*(self: Controller, publicKey: string) =
  self.contactService.addContact(publicKey)

method rejectContactRequest*(self: Controller, publicKey: string) =
  self.contactService.rejectContactRequest(publicKey)

method blockContact*(self: Controller, publicKey: string) =
  self.contactService.blockContact(publicKey)

method addGroupMembers*(self: Controller, chatId: string, pubKeys: seq[string]) =
  self.chatService.addGroupMembers(chatId, pubKeys)
  
method removeMemberFromGroupChat*(self: Controller, chatId: string, pubKey: string) =
   self.chatService.removeMemberFromGroupChat(chatId, pubKey)

method renameGroupChat*(self: Controller, chatId: string, newName: string) =
  self.chatService.renameGroupChat(chatId, newName)

method makeAdmin*(self: Controller, chatId: string, pubKey: string) =
  self.chatService.makeAdmin(chatId, pubKey)

method createGroupChat*(self: Controller, groupName: string, pubKeys: seq[string]) =
  let response = self.chatService.createGroupChat(groupName, pubKeys)
  if(response.success):
    self.delegate.addNewChat(response.chatDto, false, self.events, self.settingsService, self.contactService, self.chatService, 
    self.communityService, self.messageService, self.gifService)

method joinGroup*(self: Controller) =
  self.chatService.confirmJoiningGroup(self.getActiveChatId())

method joinGroupChatFromInvitation*(self: Controller, groupName: string, chatId: string, adminPK: string) =
  let response = self.chatService.createGroupChatFromInvitation(groupName, chatId, adminPK)
  if(response.success):
    self.delegate.addNewChat(response.chatDto, false, self.events, self.settingsService, self.contactService, self.chatService, 
    self.communityService, self.messageService, self.gifService)

method acceptRequestToJoinCommunity*(self: Controller, requestId: string) =
  self.communityService.acceptRequestToJoinCommunity(self.sectionId, requestId)

method declineRequestToJoinCommunity*(self: Controller, requestId: string) =
  self.communityService.declineRequestToJoinCommunity(self.sectionId, requestId)

method createCommunityChannel*(
    self: Controller,
    name: string,
    description: string) =
  self.communityService.createCommunityChannel(self.sectionId, name, description)

method createCommunityCategory*(self: Controller, name: string, channels: seq[string]) =
  self.communityService.createCommunityCategory(self.sectionId, name, channels)

method leaveCommunity*(self: Controller) =
  self.communityService.leaveCommunity(self.sectionId)
  
method editCommunity*(
    self: Controller,
    name: string,
    description: string,
    access: int,
    ensOnly: bool,
    color: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int) =
  self.communityService.editCommunity(
    self.sectionId,
    name,
    description,
    access,
    ensOnly,
    color,
    imageUrl,
    aX, aY, bX, bY)

method exportCommunity*(self: Controller): string =
  self.communityService.exportCommunity(self.sectionId)

method setCommunityMuted*(self: Controller, muted: bool) =
  self.communityService.setCommunityMuted(self.sectionId, muted)

method inviteUsersToCommunity*(self: Controller, pubKeys: string): string =
  result = self.communityService.inviteUsersToCommunityById(self.sectionId, pubKeys)