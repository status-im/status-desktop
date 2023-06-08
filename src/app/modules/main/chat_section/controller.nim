import Tables, sugar, sequtils, strutils

import io_interface

import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/visual_identity/service as procs_from_visual_identity_service
import ../../shared_modules/keycard_popup/io_interface as keycard_shared_module

import ../../../core/signals/types
import ../../../global/app_signals
import ../../../core/eventemitter
import ../../../core/unique_event_emitter

const UNIQUE_MAIN_MODULE_AUTH_IDENTIFIER* = "MainModule-Action-Authentication"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    sectionId: string
    isCommunitySection: bool
    activeItemId: string
    isCurrentSectionActive: bool
    events: UniqueUUIDEventEmitter
    settingsService: settings_service.Service
    nodeConfigurationService: node_configuration_service.Service
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    gifService: gif_service.Service
    mailserversService: mailservers_service.Service
    walletAccountService: wallet_account_service.Service
    tokenService: token_service.Service
    collectibleService: collectible_service.Service
    communityTokensService: community_tokens_service.Service
    tmpRequestToJoinCommunityId: string
    tmpRequestToJoinEnsName: string

proc newController*(delegate: io_interface.AccessInterface, sectionId: string, isCommunity: bool, events: EventEmitter,
  settingsService: settings_service.Service, nodeConfigurationService: node_configuration_service.Service, 
  contactService: contact_service.Service, chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  walletAccountService: wallet_account_service.Service,
  tokenService: token_service.Service,
  collectibleService: collectible_service.Service,
  communityTokensService: community_tokens_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.sectionId = sectionId
  result.isCommunitySection = isCommunity
  result.isCurrentSectionActive = false
  result.events = initUniqueUUIDEventEmitter(events)
  result.settingsService = settingsService
  result.nodeConfigurationService = nodeConfigurationService
  result.contactService = contactService
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  result.gifService = gifService
  result.mailserversService = mailserversService
  result.walletAccountService = walletAccountService
  result.tokenService = tokenService
  result.collectibleService = collectibleService
  result.communityTokensService = communityTokensService
  result.tmpRequestToJoinCommunityId = ""
  result.tmpRequestToJoinEnsName = ""

proc delete*(self: Controller) =
  self.events.disconnect()

proc getActiveChatId*(self: Controller): string =
  return self.activeItemId

proc getIsCurrentSectionActive*(self: Controller): bool =
  return self.isCurrentSectionActive

proc setIsCurrentSectionActive*(self: Controller, active: bool) =
  self.isCurrentSectionActive = active

proc requestToJoinCommunityAuthenticated*(self: Controller, password: string) =
  self.communityService.asyncRequestToJoinCommunity(self.tmpRequestToJoinCommunityId, self.tmpRequestToJoinEnsName, password)
  self.tmpRequestToJoinCommunityId = ""
  self.tmpRequestToJoinEnsName = ""

proc requestToJoinCommunity*(self: Controller, communityId: string, ensName: string) =
  self.communityService.asyncRequestToJoinCommunity(communityId, ensName, "")

proc authenticate*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_MAIN_MODULE_AUTH_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc authenticateToRequestToJoinCommunity*(self: Controller, communityId: string, ensName: string) =
  self.tmpRequestToJoinCommunityId = communityId
  self.tmpRequestToJoinEnsName = ensName
  self.authenticate()

proc getMySectionId*(self: Controller): string =
  return self.sectionId

proc asyncCheckPermissionsToJoin*(self: Controller) =
  self.communityService.asyncCheckPermissionsToJoin(self.getMySectionId())

proc asyncCheckAllChannelsPermissions*(self: Controller) =
  self.communityService.asyncCheckAllChannelsPermissions(self.getMySectionId())

proc asyncCheckChannelPermissions*(self: Controller, communityId: string, chatId: string) =
  self.communityService.asyncCheckChannelPermissions(communityId, chatId)

proc asyncCheckPermissions*(self: Controller) =
  self.asyncCheckPermissionsToJoin()
  self.asyncCheckAllChannelsPermissions()

proc init*(self: Controller) =
  self.events.on(SIGNAL_SENDING_SUCCESS) do(e:Args):
    let args = MessageSendingSuccess(e)
    self.delegate.updateLastMessageTimestamp(args.chat.id, args.chat.timestamp.int)

  self.events.on(SIGNAL_NEW_MESSAGE_RECEIVED) do(e: Args):
    let args = MessagesArgs(e)
    if (self.sectionId != args.sectionId or args.messages.len == 0):
      return
    self.delegate.onNewMessagesReceived(args.sectionId, args.chatId, args.chatType, args.lastMessageTimestamp,
      args.unviewedMessagesCount, args.unviewedMentionsCount, args.messages[0])

  self.events.on(chat_service.SIGNAL_CHAT_MUTED) do(e:Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.changeMutedOnChat(args.chatId, true)

  self.events.on(chat_service.SIGNAL_CHAT_UNMUTED) do(e:Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.changeMutedOnChat(args.chatId, false)

  self.events.on(message_service.SIGNAL_MESSAGES_MARKED_AS_READ) do(e: Args):
    let args = message_service.MessagesMarkedAsReadArgs(e)
    # update chat entity in chat service
    let chat = self.chatService.getChatById(args.chatId)
    if ((self.isCommunitySection and chat.communityId != self.sectionId) or
        (not self.isCommunitySection and chat.communityId != "")):
      return
    self.chatService.updateUnreadMessagesAndMentions(args.chatId, args.allMessagesMarked, args.messagesCount, args.messagesWithMentionsCount)
    self.delegate.onMarkAllMessagesRead(chat)

  self.events.on(chat_service.SIGNAL_CHAT_LEFT) do(e: Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.onCommunityChannelDeletedOrChatLeft(args.chatId)

  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactAdded(args.contactId)

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
    var args = ChatUpdateArgs(e)
    for chat in args.chats:
      let belongsToCommunity = chat.communityId.len > 0
      discard self.delegate.addOrUpdateChat(chat, belongsToCommunity, self.events, self.settingsService, self.nodeConfigurationService,
        self.contactService, self.chatService, self.communityService, self.messageService, self.gifService,
        self.mailserversService, setChatAsActive = false)

  self.events.on(SIGNAL_CHAT_CREATED) do(e: Args):
    var args = CreatedChatArgs(e)
    let belongsToCommunity = args.chat.communityId.len > 0
    discard self.delegate.addOrUpdateChat(args.chat, belongsToCommunity, self.events, self.settingsService, self.nodeConfigurationService,
      self.contactService, self.chatService, self.communityService, self.messageService, self.gifService,
      self.mailserversService, setChatAsActive = true)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_MAIN_MODULE_AUTH_IDENTIFIER:
      return
    if self.tmpRequestToJoinCommunityId == self.sectionId:
      self.delegate.onUserAuthenticated(args.pin, args.password, args.keyUid)

  if (self.isCommunitySection):
    self.events.on(SIGNAL_COMMUNITY_CHANNEL_CREATED) do(e:Args):
      let args = CommunityChatArgs(e)
      let belongsToCommunity = args.chat.communityId.len > 0
      discard self.delegate.addOrUpdateChat(args.chat, belongsToCommunity, self.events, self.settingsService,
        self.nodeConfigurationService, self.contactService, self.chatService, self.communityService,
        self.messageService, self.gifService, self.mailserversService, setChatAsActive = true)

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
        self.delegate.onCommunityCategoryCreated(args.category, args.chats, args.communityId)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_DELETED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityCategoryDeleted(args.category, args.chats)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_EDITED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityCategoryEdited(args.category, args.chats)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_REORDERED) do(e:Args):
      let args = CommunityCategoryOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onReorderCategory(args.categoryId, args.position)

    self.events.on(SIGNAL_COMMUNITY_CATEGORY_NAME_EDITED) do(e:Args):
      let args = CommunityCategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCategoryNameChanged(args.category)

    self.events.on(SIGNAL_COMMUNITY_CHANNEL_REORDERED) do(e:Args):
      let args = CommunityChatOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onReorderChat(args.chat)

    self.events.on(SIGNAL_COMMUNITY_CHANNELS_REORDERED) do(e:Args):
      let args = CommunityChatsOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onReorderChats(args.chats)

    self.events.on(SIGNAL_COMMUNITY_CHANNEL_CATEGORY_CHANGED) do(e:Args):
      let args = CommunityChatOrderArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onReorderChat(args.chat)

    self.events.on(SIGNAL_RELOAD_MESSAGES) do(e: Args):
      let args = ReloadMessagesArgs(e)
      if (args.communityId == self.sectionId):
        self.messageService.asyncLoadInitialMessagesForChat(self.getActiveChatId())
    
    self.events.on(SIGNAL_CATEGORY_MUTED) do(e: Args):
      let args = CategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCategoryMuted(args.categoryId)
    
    self.events.on(SIGNAL_CATEGORY_UNMUTED) do(e: Args):
      let args = CategoryArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCategoryUnmuted(args.categoryId)

    self.events.on(SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATED) do(e: Args):
      let args = CommunityTokenPermissionArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenPermissionCreated(args.communityId, args.tokenPermission)
        self.asyncCheckPermissions()

    self.events.on(SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATION_FAILED) do(e: Args):
      let args = CommunityTokenPermissionArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenPermissionCreationFailed(args.communityId)

    self.events.on(SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATED) do(e: Args):
      let args = CommunityTokenPermissionArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenPermissionUpdated(args.communityId, args.tokenPermission)
        self.asyncCheckPermissions()


    self.events.on(SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATE_FAILED) do(e: Args):
      let args = CommunityTokenPermissionArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenPermissionUpdateFailed(args.communityId)

    self.events.on(SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETED) do(e: Args):
      let args = CommunityTokenPermissionRemovedArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenPermissionDeleted(args.communityId, args.permissionId)
        self.asyncCheckPermissions()

    self.events.on(SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETION_FAILED) do(e: Args):
      let args = CommunityTokenPermissionArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenPermissionDeletionFailed(args.communityId)

    self.events.on(SIGNAL_CHECK_PERMISSIONS_TO_JOIN_RESPONSE) do(e: Args):
      let args = CheckPermissionsToJoinResponseArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityCheckPermissionsToJoinResponse(args.checkPermissionsToJoinResponse)

    self.events.on(SIGNAL_CHECK_CHANNEL_PERMISSIONS_RESPONSE) do(e: Args):
      let args = CheckChannelPermissionsResponseArgs(e)
      if args.communityId == self.sectionId:
        self.delegate.onCommunityCheckChannelPermissionsResponse(args.chatId, args.checkChannelPermissionsResponse)

    self.events.on(SIGNAL_CHECK_ALL_CHANNELS_PERMISSIONS_RESPONSE) do(e: Args):
      let args = CheckAllChannelsPermissionsResponseArgs(e)
      if args.communityId == self.sectionId:
        self.delegate.onCommunityCheckAllChannelsPermissionsResponse(args.checkAllChannelsPermissionsResponse)

    self.events.on(SIGNAL_COMMUNITY_TOKEN_METADATA_ADDED) do(e: Args):
      let args = CommunityTokenMetadataArgs(e)
      if (args.communityId == self.sectionId):
        self.delegate.onCommunityTokenMetadataAdded(args.communityId, args.tokenMetadata)

    self.events.on(SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED) do(e: Args):
      self.delegate.onOwnedCollectiblesUpdated()
      self.asyncCheckPermissions()

    self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e: Args):
      self.delegate.onWalletAccountTokensRebuilt()
      self.asyncCheckPermissions()

    self.events.on(SIGNAL_COMMUNITY_KICKED) do (e: Args):
      let args = CommunityArgs(e)
      if (args.community.id == self.sectionId):
        self.delegate.onKickedFromCommunity()

    self.events.on(SIGNAL_COMMUNITY_JOINED) do (e: Args):
      let args = CommunityArgs(e)
      if (args.community.id == self.sectionId):
        self.delegate.onJoinedCommunity()

    self.events.on(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED_NO_PERMISSION) do(e: Args):
      var args = CommunityMemberArgs(e)
      self.delegate.onAcceptRequestToJoinFailedNoPermission(args.communityId, args.pubKey, args.requestId)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.onContactDetailsUpdated(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNTRUSTWORTHY) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.onContactDetailsUpdated(args.publicKey)

  self.events.on(SIGNAL_CONTACT_TRUSTED) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.onContactDetailsUpdated(args.publicKey)

  self.events.on(SIGNAL_REMOVED_TRUST_STATUS) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.onContactDetailsUpdated(args.publicKey)

  self.events.on(SIGNAL_CHAT_RENAMED) do(e: Args):
    var args = ChatRenameArgs(e)
    self.delegate.onChatRenamed(args.id, args.newName)

  self.events.on(SIGNAL_GROUP_CHAT_DETAILS_UPDATED) do(e: Args):
    var args = ChatUpdateDetailsArgs(e)
    self.delegate.onGroupChatDetailsUpdated(args.id, args.newName, args.newColor, args.newImage)

  self.events.on(SIGNAL_MAKE_SECTION_CHAT_ACTIVE) do(e: Args):
    var args = ActiveSectionChatArgs(e)
    if (self.sectionId != args.sectionId):
      return
    self.delegate.makeChatWithIdActive(args.chatId)
    
  if (not self.isCommunitySection):
    self.events.on(SIGNAL_CHAT_SWITCH_TO_OR_CREATE_1_1_CHAT) do(e:Args):
      let args = ChatExtArgs(e)
      self.delegate.createOneToOneChat(args.communityId, args.chatId, args.ensName)

  self.events.on(SIGNAL_CONTACTS_STATUS_UPDATED) do(e: Args):
    let args = ContactsStatusUpdatedArgs(e)
    self.delegate.contactsStatusUpdated(args.statusUpdates)

  self.events.on(SIGNAL_MAILSERVER_HISTORY_REQUEST_STARTED) do(e: Args):
    self.delegate.setLoadingHistoryMessagesInProgress(true)

  self.events.on(SIGNAL_MAILSERVER_HISTORY_REQUEST_COMPLETED) do(e:Args):
    self.delegate.setLoadingHistoryMessagesInProgress(false)

proc isCommunity*(self: Controller): bool =
  return self.isCommunitySection

proc getCommunityById*(self: Controller, communityId: string): CommunityDto =
  return self.communityService.getCommunityById(communityId)

proc getMyCommunity*(self: Controller): CommunityDto =
  return self.getCommunityById(self.sectionId)

proc getCategories*(self: Controller, communityId: string): seq[Category] =
  return self.communityService.getCategories(communityId)

proc getChats*(self: Controller, communityId: string, categoryId: string): seq[ChatDto] =
  return self.communityService.getChats(communityId, categoryId)

proc getAllChats*(self: Controller, communityId: string): seq[ChatDto] =
  return self.communityService.getAllChats(communityId)

proc getChatsAndBuildUI*(self: Controller) =
  let channelGroup = self.chatService.getChannelGroupById(self.sectionId)
  self.delegate.onChatsLoaded(
        channelGroup,
        self.events,
        self.settingsService,
        self.nodeConfigurationService,
        self.contactService,
        self.chatService,
        self.communityService,
        self.messageService,
        self.gifService,
        self.mailserversService,
      )

proc sectionUnreadMessagesAndMentionsCount*(self: Controller, communityId: string):
    tuple[unviewedMessagesCount: int, unviewedMentionsCount: int] =
  return self.chatService.sectionUnreadMessagesAndMentionsCount(communityId)

proc getChatDetails*(self: Controller, chatId: string): ChatDto =
  return self.chatService.getChatById(chatId)

proc getChatDetailsForChatTypes*(self: Controller, types: seq[ChatType]): seq[ChatDto] =
  return self.chatService.getChatsOfChatTypes(types)

proc chatsWithCategoryHaveUnreadMessages*(self: Controller, communityId: string, categoryId: string): bool =
  return self.chatService.chatsWithCategoryHaveUnreadMessages(communityId, categoryId)

proc getCommunityCategoryDetails*(self: Controller, communityId: string, categoryId: string): Category =
  return self.communityService.getCategoryById(communityId, categoryId)

proc setActiveItem*(self: Controller, itemId: string) =
  self.activeItemId = itemId
  let isSectionActive = self.getIsCurrentSectionActive()
  if not isSectionActive:
    return
  if self.activeItemId != "":
    self.messageService.asyncLoadInitialMessagesForChat(self.activeItemId)

  # We need to take other actions here like notify status go that unviewed mentions count is updated and so...
  self.delegate.activeItemSet(self.activeItemId)

proc removeCommunityChat*(self: Controller, itemId: string) =
  self.communityService.deleteCommunityChat(self.getMySectionId(), itemId)

proc getOneToOneChatNameAndImage*(self: Controller, chatId: string):
    tuple[name: string, image: string, largeImage: string] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

proc createOneToOneChat*(self: Controller, communityID: string, chatId: string, ensName: string) =
  let response = self.chatService.createOneToOneChat(communityID, chatId, ensName)
  if(response.success):
    discard self.delegate.addOrUpdateChat(response.chatDto, false, self.events, self.settingsService, self.nodeConfigurationService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc switchToOrCreateOneToOneChat*(self: Controller, chatId: string, ensName: string) =
  self.chatService.switchToOrCreateOneToOneChat(chatId, ensName)

proc leaveChat*(self: Controller, chatId: string) =
  self.chatService.leaveChat(chatId)

proc muteChat*(self: Controller, chatId: string, interval: int) =
  self.chatService.muteChat(chatId, interval)

proc unmuteChat*(self: Controller, chatId: string) =
  self.chatService.unmuteChat(chatId)

proc markAllMessagesRead*(self: Controller, chatId: string) =
  self.messageService.markAllMessagesRead(chatId)

proc clearChatHistory*(self: Controller, chatId: string) =
  self.chatService.clearChatHistory(chatId)

proc getCurrentFleet*(self: Controller): string =
  return self.nodeConfigurationService.getFleetAsString()

proc getContacts*(self: Controller, group: ContactsGroup): seq[ContactsDto] =
  return self.contactService.getContactsByGroup(group)

proc getContactById*(self: Controller, id: string): ContactsDto =
  return self.contactService.getContactById(id)

proc getContactDetails*(self: Controller, id: string): ContactDetails =
  return self.contactService.getContactDetails(id)

proc getStatusForContactWithId*(self: Controller, publicKey: string): StatusUpdateDto =
  return self.contactService.getStatusForContactWithId(publicKey)

proc acceptContactRequest*(self: Controller, publicKey: string, contactRequestId: string) =
  self.contactService.acceptContactRequest(publicKey, contactRequestId)

proc dismissContactRequest*(self: Controller, publicKey: string, contactRequestId: string) =
  self.contactService.dismissContactRequest(publicKey, contactRequestId)

proc blockContact*(self: Controller, publicKey: string) =
  self.contactService.blockContact(publicKey)

proc addGroupMembers*(self: Controller, chatId: string, pubKeys: seq[string]) =
  let communityId = if self.isCommunitySection: self.sectionId else: ""
  self.chatService.addGroupMembers(communityId, chatId, pubKeys)

proc removeMemberFromGroupChat*(self: Controller, communityID: string, chatId: string, pubKey: string) =
   self.chatService.removeMemberFromGroupChat(communityID, chatId, pubKey)

proc removeMembersFromGroupChat*(self: Controller, communityID: string, chatId: string, pubKeys: seq[string]) =
   self.chatService.removeMembersFromGroupChat(communityID, chatId, pubKeys)

proc renameGroupChat*(self: Controller, chatId: string, newName: string) =
  let communityId = if self.isCommunitySection: self.sectionId else: ""
  self.chatService.renameGroupChat(communityId, chatId, newName)

proc updateGroupChatDetails*(self: Controller, chatId: string, newGroupName: string, newGroupColor: string, newGroupImageJson: string) =
  let communityId = if self.isCommunitySection: self.sectionId else: ""
  self.chatService.updateGroupChatDetails(communityId, chatId, newGroupName, newGroupColor, newGroupImageJson)

proc makeAdmin*(self: Controller, communityID: string, chatId: string, pubKey: string) =
  self.chatService.makeAdmin(communityID, chatId, pubKey)

proc createGroupChat*(self: Controller, communityID: string, groupName: string, pubKeys: seq[string]) =
  let response = self.chatService.createGroupChat(communityID, groupName, pubKeys)
  if(response.success):
    discard self.delegate.addOrUpdateChat(response.chatDto, false, self.events, self.settingsService, self.nodeConfigurationService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc joinGroupChatFromInvitation*(self: Controller, groupName: string, chatId: string, adminPK: string) =
  let response = self.chatService.createGroupChatFromInvitation(groupName, chatId, adminPK)
  if(response.success):
    discard self.delegate.addOrUpdateChat(response.chatDto, false, self.events, self.settingsService, self.nodeConfigurationService,
      self.contactService, self.chatService, self.communityService, self.messageService,
      self.gifService, self.mailserversService)

proc acceptRequestToJoinCommunity*(self: Controller, requestId: string, communityId: string) =
  self.communityService.asyncAcceptRequestToJoinCommunity(communityId, requestId)

proc declineRequestToJoinCommunity*(self: Controller, requestId: string, communityId: string) =
  self.communityService.declineRequestToJoinCommunity(communityId, requestId)

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

proc banUserFromCommunity*(self: Controller, pubKey: string) =
  self.communityService.banUserFromCommunity(self.sectionId, pubKey)

proc unbanUserFromCommunity*(self: Controller, pubKey: string) =
  self.communityService.unbanUserFromCommunity(self.sectionId, pubKey)

proc editCommunity*(
    self: Controller,
    name: string,
    description: string,
    introMessage: string,
    outroMessage: string,
    access: int,
    color: string,
    tags: string,
    logoJsonStr: string,
    bannerJsonStr: string,
    historyArchiveSupportEnabled: bool,
    pinMessageAllMembersEnabled: bool) =
  self.communityService.editCommunity(
    self.sectionId,
    name,
    description,
    introMessage,
    outroMessage,
    access,
    color,
    tags,
    logoJsonStr,
    bannerJsonStr,
    historyArchiveSupportEnabled,
    pinMessageAllMembersEnabled)

proc exportCommunity*(self: Controller): string =
  self.communityService.exportCommunity(self.sectionId)

proc muteCategory*(self: Controller, categoryId: string, interval: int) =
  self.communityService.muteCategory(self.sectionId, categoryId, interval)

proc unmuteCategory*(self: Controller, categoryId: string) =
  self.communityService.unmuteCategory(self.sectionId, categoryId)

proc setCommunityMuted*(self: Controller, muted: bool) =
  self.communityService.setCommunityMuted(self.sectionId, muted)

proc inviteUsersToCommunity*(self: Controller, pubKeys: string, inviteMessage: string): string =
  result = self.communityService.inviteUsersToCommunityById(self.sectionId, pubKeys, inviteMessage)

proc reorderCommunityCategories*(self: Controller, categoryId: string, position: int) =
  self.communityService.reorderCommunityCategories(self.sectionId, categoryId, position)

proc reorderCommunityChat*(self: Controller, categoryId: string, chatId: string, position: int) =
  self.communityService.reorderCommunityChat(self.sectionId, categoryId, chatId, position)

proc getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText], communityChats: seq[ChatDto]): string =
  return self.messageService.getRenderedText(parsedTextArray, communityChats)

proc getColorHash*(self: Controller, pubkey: string): ColorHashDto =
  procs_from_visual_identity_service.colorHashOf(pubkey)

proc getColorId*(self: Controller, pubkey: string): int =
  procs_from_visual_identity_service.colorIdOf(pubkey)

proc checkChatHasPermissions*(self: Controller, communityId: string, chatId: string): bool =
  return self.communityService.checkChatHasPermissions(communityId, chatId)

proc checkChatIsLocked*(self: Controller, communityId: string, chatId: string): bool =
  return self.communityService.checkChatIsLocked(communityId, chatId)

proc createOrEditCommunityTokenPermission*(self: Controller, communityId: string, tokenPermission: CommunityTokenPermissionDto) =
  self.communityService.createOrEditCommunityTokenPermission(communityId, tokenPermission)

proc deleteCommunityTokenPermission*(self: Controller, communityId: string, permissionId: string) =
  self.communityService.deleteCommunityTokenPermission(communityId, permissionId)

proc allAccountsTokenBalance*(self: Controller, symbol: string): float64 =
  return self.walletAccountService.allAccountsTokenBalance(symbol)

proc ownsCollectible*(self: Controller, chainId: int, contractAddress: string, tokenIds: seq[string]): bool =
  let addresses = self.walletAccountService.getWalletAccounts().filter(a => a.walletType != WalletTypeWatch).map(a => a.address)

  for address in addresses:
    let data = self.collectibleService.getOwnedCollectibles(chainId, @[address])
    
    for collectible in data[0].collectibles:
      if collectible.id.contractAddress == contractAddress.toLowerAscii:
        return true

  return false

proc getTokenList*(self: Controller): seq[TokenDto] =
  return self.tokenService.getTokenList()

proc getTokenDecimals*(self: Controller, symbol: string): int =
  return self.tokenService.getTokenDecimals(symbol)

proc getContractAddressesForToken*(self: Controller, symbol: string): Table[int, string] =
  var contractAddresses = self.tokenService.getContractAddressesForToken(symbol)
  let communityToken = self.communityService.getCommunityTokenBySymbol(self.getMySectionId(), symbol)
  if communityToken.address != "":
    contractAddresses[communityToken.chainId] = communityToken.address
  return contractAddresses

proc getCommunityTokenList*(self: Controller): seq[CommunityTokenDto] =
  return self.communityTokensService.getCommunityTokens(self.getMySectionId())

