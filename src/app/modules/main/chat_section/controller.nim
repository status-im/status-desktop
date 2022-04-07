import Tables

import io_interface

import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../app_service/service/visual_identity/service as procs_from_visual_identity_service

import ../../../core/signals/types
import ../../../global/app_signals
import ../../../core/eventemitter


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    sectionId: string
    isCommunitySection: bool
    activeItemId: string
    activeSubItemId: string
    events: EventEmitter
    settingsService: settings_service.Service
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    gifService: gif_service.Service
    mailserversService: mailservers_service.Service

proc newController*(delegate: io_interface.AccessInterface, sectionId: string, isCommunity: bool, events: EventEmitter,
  settingsService: settings_service.Service, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service): Controller =
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
  result.mailserversService = mailserversService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_NEW_MESSAGE_RECEIVED) do(e: Args):
    let args = MessagesArgs(e)
    if(self.isCommunitySection and args.chatType != ChatType.CommunityChat or
      not self.isCommunitySection and args.chatType == ChatType.CommunityChat):
        return
    self.delegate.onNewMessagesReceived(args.chatId, args.unviewedMessagesCount, args.unviewedMentionsCount,
    args.messages)

  self.events.on(message_service.SIGNAL_MENTIONED_IN_EDITED_MESSAGE) do(e: Args):
    let args = MessageEditedArgs(e)
    self.delegate.onMeMentionedInEditedMessage(args.chatId, args.message)

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

  self.events.on(SIGNAL_CONTACT_UNBLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactUnblocked(args.contactId)

  self.events.on(SIGNAL_CHAT_UPDATE) do(e: Args):
    var args = ChatUpdateArgsNew(e)
    for chat in args.chats:
      let belongsToCommunity = chat.communityId.len > 0
      self.delegate.addChatIfDontExist(chat, belongsToCommunity, self.events, self.settingsService,
        self.contactService, self.chatService, self.communityService, self.messageService, self.gifService,
        self.mailserversService, setChatAsActive = false)

  if (self.isCommunitySection):
    self.events.on(SIGNAL_COMMUNITY_CHANNEL_CREATED) do(e:Args):
      let args = CommunityChatArgs(e)
      let belongsToCommunity = args.chat.communityId.len > 0
      self.delegate.addChatIfDontExist(args.chat, belongsToCommunity, self.events, self.settingsService,
        self.contactService, self.chatService, self.communityService, self.messageService, self.gifService,
        self.mailserversService, setChatAsActive = true)

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

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_DELETED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityCategoryDeleted(args.category)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_EDITED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityCategoryEdited(args.category, args.chats)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_REORDERED) do(e:Args):
      let args = CommunityChatOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onReorderChatOrCategory(args.categoryId, args.position)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_NAME_EDITED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCategoryNameChanged(args.category)

    self.events.on(SIGNAL_COMMUNITY_CHANNEL_REORDERED) do(e:Args):
      let args = CommunityChatOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onReorderChatOrCategory(args.chatId, args.position)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CHAT_RENAMED) do(e: Args):
    var args = ChatRenameArgs(e)
    self.delegate.onChatRenamed(args.id, args.newName)

  self.events.on(SIGNAL_MAKE_SECTION_CHAT_ACTIVE) do(e: Args):
    var args = ActiveSectionChatArgs(e)
    if (self.sectionId != args.sectionId):
      return
    self.delegate.makeChatWithIdActive(args.chatId)

  self.events.on(SIGNAL_CHAT_SWITCH_TO_OR_CREATE_1_1_CHAT) do(e:Args):
    let args = ChatExtArgs(e)
    if (self.isCommunitySection):
      return
    self.delegate.createOneToOneChat(args.communityId, args.chatId, args.ensName)

  self.events.on(SignalType.HistoryRequestStarted.event) do(e: Args):
    self.delegate.setLoadingHistoryMessagesInProgress(true)

  self.events.on(SignalType.HistoryRequestCompleted.event) do(e:Args):
    self.delegate.setLoadingHistoryMessagesInProgress(false)

  self.events.on(SignalType.HistoryRequestFailed.event) do(e:Args):
    discard

proc getMySectionId*(self: Controller): string =
  return self.sectionId

proc getActiveChatId*(self: Controller): string =
  if(self.activeSubItemId.len > 0):
    return self.activeSubItemId
  else:
    return self.activeItemId

proc isCommunity*(self: Controller): bool =
  return self.isCommunitySection

proc getJoinedCommunities*(self: Controller): seq[CommunityDto] =
  return self.communityService.getJoinedCommunities()

proc getMyCommunity*(self: Controller): CommunityDto =
  return self.communityService.getCommunityById(self.sectionId)

proc getCategories*(self: Controller, communityId: string): seq[Category] =
  return self.communityService.getCategories(communityId)

proc getChats*(self: Controller, communityId: string, categoryId: string): seq[ChatDto] =
  return self.communityService.getChats(communityId, categoryId)

proc getChatDetails*(self: Controller, communityId, chatId: string): ChatDto =
  let fullId = communityId & chatId
  return self.chatService.getChatById(fullId)

proc getChatDetailsForChatTypes*(self: Controller, types: seq[ChatType]): seq[ChatDto] =
  return self.chatService.getChatsOfChatTypes(types)

proc setActiveItemSubItem*(self: Controller, itemId: string, subItemId: string) =
  self.activeItemId = itemId
  self.activeSubItemId = subItemId

  self.messageService.asyncLoadInitialMessagesForChat(self.getActiveChatId())

  # We need to take other actions here like notify status go that unviewed mentions count is updated and so...

  self.delegate.activeItemSubItemSet(self.activeItemId, self.activeSubItemId)

proc removeCommunityChat*(self: Controller, itemId: string) =
  self.communityService.deleteCommunityChat(self.getMySectionId(), itemId)

proc getOneToOneChatNameAndImage*(self: Controller, chatId: string):
  tuple[name: string, image: string] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

proc createPublicChat*(self: Controller, chatId: string) =
  let response = self.chatService.createPublicChat(chatId)
  if(response.success):
    self.delegate.addChatIfDontExist(response.chatDto, false, self.events, self.settingsService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc createOneToOneChat*(self: Controller, communityID: string, chatId: string, ensName: string) =
  let response = self.chatService.createOneToOneChat(communityID, chatId, ensName)
  if(response.success):
    self.delegate.addChatIfDontExist(response.chatDto, false, self.events, self.settingsService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc switchToOrCreateOneToOneChat*(self: Controller, chatId: string, ensName: string) =
  self.chatService.switchToOrCreateOneToOneChat(chatId, ensName)

proc leaveChat*(self: Controller, chatId: string) =
  self.chatService.leaveChat(chatId)

proc muteChat*(self: Controller, chatId: string) =
  self.chatService.muteChat(chatId)

proc unmuteChat*(self: Controller, chatId: string) =
  self.chatService.unmuteChat(chatId)

proc markAllMessagesRead*(self: Controller, chatId: string) =
  self.messageService.markAllMessagesRead(chatId)

proc clearChatHistory*(self: Controller, chatId: string) =
  self.chatService.clearChatHistory(chatId)

proc getCurrentFleet*(self: Controller): string =
  return self.settingsService.getFleetAsString()

proc getContacts*(self: Controller, group: ContactsGroup): seq[ContactsDto] =
  return self.contactService.getContactsByGroup(group)

proc getContactDetails*(self: Controller, id: string): ContactDetails =
  return self.contactService.getContactDetails(id)

proc addContact*(self: Controller, publicKey: string) =
  self.contactService.addContact(publicKey)

proc rejectContactRequest*(self: Controller, publicKey: string) =
  self.contactService.rejectContactRequest(publicKey)

proc blockContact*(self: Controller, publicKey: string) =
  self.contactService.blockContact(publicKey)

proc addGroupMembers*(self: Controller, communityID: string, chatId: string, pubKeys: seq[string]) =
  self.chatService.addGroupMembers(communityID, chatId, pubKeys)

proc removeMemberFromGroupChat*(self: Controller, communityID: string, chatId: string, pubKey: string) =
   self.chatService.removeMemberFromGroupChat(communityID, chatId, pubKey)

proc renameGroupChat*(self: Controller, communityID: string, chatId: string, newName: string) =
  self.chatService.renameGroupChat(communityID, chatId, newName)

proc makeAdmin*(self: Controller, communityID: string, chatId: string, pubKey: string) =
  self.chatService.makeAdmin(communityID, chatId, pubKey)

proc createGroupChat*(self: Controller, communityID: string, groupName: string, pubKeys: seq[string]) =
  let response = self.chatService.createGroupChat(communityID, groupName, pubKeys)
  if(response.success):
    self.delegate.addChatIfDontExist(response.chatDto, false, self.events, self.settingsService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc confirmJoiningGroup*(self: Controller, communityID: string, chatID: string) =
  self.chatService.confirmJoiningGroup(communityID, self.getActiveChatId())

proc joinGroupChatFromInvitation*(self: Controller, groupName: string, chatId: string, adminPK: string) =
  let response = self.chatService.createGroupChatFromInvitation(groupName, chatId, adminPK)
  if(response.success):
    self.delegate.addChatIfDontExist(response.chatDto, false, self.events, self.settingsService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc acceptRequestToJoinCommunity*(self: Controller, requestId: string) =
  self.communityService.acceptRequestToJoinCommunity(self.sectionId, requestId)

proc declineRequestToJoinCommunity*(self: Controller, requestId: string) =
  self.communityService.declineRequestToJoinCommunity(self.sectionId, requestId)

proc createCommunityChannel*(
    self: Controller,
    name: string,
    description: string,
    emoji: string,
    color: string,
    categoryId: string) =
  self.communityService.createCommunityChannel(self.sectionId, name, description, emoji, color,
    categoryId)

proc editCommunityChannel*(
    self: Controller,
    channelId: string,
    name: string,
    description: string,
    emoji: string,
    color: string,
    categoryId: string,
    position: int) =
  self.communityService.editCommunityChannel(
    self.sectionId,
    channelId,
    name,
    description,
    emoji,
    color,
    categoryId,
    position)

proc createCommunityCategory*(self: Controller, name: string, channels: seq[string]) =
  self.communityService.createCommunityCategory(self.sectionId, name, channels)

proc editCommunityCategory*(self: Controller, categoryId: string, name: string, channels: seq[string]) =
  self.communityService.editCommunityCategory(self.sectionId, categoryId, name, channels)

proc deleteCommunityCategory*(self: Controller, categoryId: string) =
  self.communityService.deleteCommunityCategory(self.sectionId, categoryId)

proc leaveCommunity*(self: Controller) =
  self.communityService.leaveCommunity(self.sectionId)

proc removeUserFromCommunity*(self: Controller, pubKey: string) =
  self.communityService.removeUserFromCommunity(self.sectionId, pubKey)

proc editCommunity*(
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

proc exportCommunity*(self: Controller): string =
  self.communityService.exportCommunity(self.sectionId)

proc setCommunityMuted*(self: Controller, muted: bool) =
  self.communityService.setCommunityMuted(self.sectionId, muted)

proc inviteUsersToCommunity*(self: Controller, pubKeys: string): string =
  result = self.communityService.inviteUsersToCommunityById(self.sectionId, pubKeys)

proc reorderCommunityCategories*(self: Controller, categoryId: string, position: int) =
  self.communityService.reorderCommunityCategories(self.sectionId, categoryId, position)

proc reorderCommunityChat*(self: Controller, categoryId: string, chatId: string, position: int): string =
  self.communityService.reorderCommunityChat(self.sectionId, categoryId, chatId, position)

proc getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText]): string =
  return self.messageService.getRenderedText(parsedTextArray)

proc getColorHash*(self: Controller, pubkey: string): ColorHashDto =
  procs_from_visual_identity_service.colorHashOf(pubkey)
