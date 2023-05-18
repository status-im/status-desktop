import NimQml, Tables, chronicles, json, sequtils, strutils, strformat, sugar

import io_interface
import ../io_interface as delegate_interface
import view, controller, active_item
import model as chats_model
import item as chat_item
import ../../shared_models/user_item as user_item
import ../../shared_models/user_model as user_model
import ../../shared_models/token_permissions_model
import ../../shared_models/token_permission_item
import ../../shared_models/token_criteria_item
import ../../shared_models/token_criteria_model
import ../../shared_models/token_list_item
import ../../shared_models/token_list_model

import chat_content/module as chat_content_module
import chat_content/users/module as users_module

import ../../../global/app_sections_config as conf
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../core/unique_event_emitter
import ../../../core/notifications/details as notification_details
import ../../../../app_service/common/types
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../../app_service/service/visual_identity/service as visual_identity
import ../../../../app_service/service/contacts/dto/contacts as contacts_dto
import ../../../../app_service/service/community/dto/community as community_dto

export io_interface

logScope:
  topics = "chat-section-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    chatContentModules: OrderedTable[string, chat_content_module.AccessInterface]
    moduleLoaded: bool
    chatsLoaded: bool
    usersModule: users_module.AccessInterface

# Forward declaration
proc buildChatSectionUI(self: Module,
  channelGroup: ChannelGroupDto,
  events: UniqueUUIDEventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service)

proc addOrUpdateChat(self: Module,
    chat: ChatDto,
    channelGroup: ChannelGroupDto,
    belongsToCommunity: bool,
    events: UniqueUUIDEventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    setChatAsActive: bool = true,
    insertIntoModel: bool = true,
  ): Item

proc buildTokenPermissionItem*(self: Module, tokenPermission: CommunityTokenPermissionDto): TokenPermissionItem

proc buildTokenList*(self: Module)

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    sectionId: string,
    isCommunity: bool,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    walletAccountService: wallet_account_service.Service,
    tokenService: token_service.Service,
    collectibleService: collectible_service.Service,
    communityTokensService: community_tokens_service.Service,
  ): Module =
  result = Module()
  result.delegate = delegate
  result.controller = controller.newController(result, sectionId, isCommunity, events, settingsService, nodeConfigurationService,
  contactService, chatService, communityService, messageService, gifService, mailserversService, walletAccountService, tokenService, collectibleService, communityTokensService)
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.chatsLoaded = false

  result.chatContentModules = initOrderedTable[string, chat_content_module.AccessInterface]()

  # Simple community channels uses comminity usersModule while chats uses their own usersModule
  if isCommunity:
    result.usersModule = users_module.newModule(
      events, sectionId, chatId = "", belongsToCommunity = true, isUsersListAvailable = true,
      contactService, chat_service, communityService, messageService)

method delete*(self: Module) =
  self.controller.delete
  self.view.delete
  self.viewVariant.delete
  for cModule in self.chatContentModules.values:
    cModule.delete
  self.chatContentModules.clear
  if self.usersModule != nil:
    self.usersModule.delete

method isCommunity*(self: Module): bool =
  return self.controller.isCommunity()

method getMySectionId*(self: Module): string =
  return self.controller.getMySectionId()

proc amIMarkedAsAdminUser(self: Module, members: seq[ChatMember]): bool =
  for m in members:
    if (m.id == singletonInstance.userProfile.getPubKey() and m.admin):
      return true
  return false

proc addSubmodule(self: Module, chatId: string, belongToCommunity: bool, isUsersListAvailable: bool, events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service) =
  self.chatContentModules[chatId] = chat_content_module.newModule(self, events, self.controller.getMySectionId(), chatId,
    belongToCommunity, isUsersListAvailable, settingsService, nodeConfigurationService, contactService, chatService, communityService,
    messageService, gifService, mailserversService, self.usersModule)

proc removeSubmodule(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.chatContentModules.del(chatId)


proc addCategoryItem(self: Module, category: Category, amIAdmin: bool, communityId: string, insertIntoModel: bool = true): Item =
  let hasUnreadMessages = self.controller.chatsWithCategoryHaveUnreadMessages(communityId, category.id)
  result = chat_item.initItem(
        id = category.id,
        category.name,
        icon = "",
        color = "",
        emoji = "",
        description = "",
        `type` = chat_item.CATEGORY_TYPE,
        amIAdmin,
        lastMessageTimestamp = 0,
        hasUnreadMessages,
        notificationsCount = 0,
        muted = false,
        blocked = false,
        active = false,
        position = -1, # Set position as -1, so that the Category Item is on top of its Channels
        category.id,
        category.position,
      )
  if insertIntoModel:
    self.view.chatsModel().appendItem(result)

proc buildChatSectionUI(
    self: Module,
    channelGroup: ChannelGroupDto,
    events: UniqueUUIDEventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service) =
  var selectedItemId = ""
  let sectionLastOpenChat = singletonInstance.localAccountSensitiveSettings.getSectionLastOpenChat(self.controller.getMySectionId())

  var items: seq[Item] = @[]
  for categoryDto in channelGroup.categories:
    # Add items for the categories. We use a special type to identify categories
    items.add(self.addCategoryItem(categoryDto, channelGroup.admin, channelGroup.id))

  for chatDto in channelGroup.chats:
    var categoryPosition = -1

    # Add an empty chat item that has the category info
    var isActive = false
    # restore on a startup last open channel for the section or
    # make the first channel which doesn't belong to any category active
    if (selectedItemId.len == 0 and sectionLastOpenChat.len == 0) or chatDto.id == sectionLastOpenChat:
      selectedItemId = chatDto.id
      isActive = true

    if chatDto.categoryId != "":
      for category in channelGroup.categories:
        if category.id == chatDto.categoryId:
          categoryPosition = category.position
          break

    items.add(self.addOrUpdateChat(
      chatDto,
      channelGroup,
      belongsToCommunity = chatDto.communityId.len > 0,
      events,
      settingsService,
      nodeConfigurationService,
      contactService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService,
      setChatAsActive = false,
      insertIntoModel = false
    ))

  self.view.chatsModel.setData(items)
  self.setActiveItem(selectedItemId)

proc createItemFromPublicKey(self: Module, publicKey: string): UserItem =
  let contactDetails = self.controller.getContactDetails(publicKey)

  return initUserItem(
    pubKey = contactDetails.details.id,
    displayName = contactDetails.details.displayName,
    ensName = contactDetails.details.name,
    isEnsVerified = contactDetails.details.ensVerified,
    localNickname = contactDetails.details.localNickname,
    alias = contactDetails.details.alias,
    icon = contactDetails.icon,
    colorId = contactDetails.colorId,
    colorHash = contactDetails.colorHash,
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(publicKey).statusType),
    isContact = contactDetails.details.isContact(),
    isVerified = contactDetails.details.isContactVerified(),
    isUntrustworthy = contactDetails.details.isContactUntrustworthy(),
    isBlocked = contactDetails.details.isBlocked(),
  )

proc initContactRequestsModel(self: Module) =
  var contactsWhoAddedMe: seq[UserItem]
  let contacts =  self.controller.getContacts(ContactsGroup.IncomingPendingContactRequests)
  for c in contacts:
    let item = self.createItemFromPublicKey(c.id)
    contactsWhoAddedMe.add(item)

  self.view.contactRequestsModel().addItems(contactsWhoAddedMe)

proc rebuildCommunityTokenPermissionsModel(self: Module) =
  self.buildTokenList()

  let community = self.controller.getMyCommunity()
  var tokenPermissionsItems: seq[TokenPermissionItem] = @[]
  var allTokenRequirementsMet = false

  for id, tokenPermission in community.tokenPermissions:
    # TODO: for startes we only deal with "become member" permissions
    if tokenPermission.`type` == TokenPermissionType.BecomeMember:
      let tokenPermissionItem = self.buildTokenPermissionItem(tokenPermission)

      # multiple permissions of the same type act as logical OR
      # so if at least one of them is fulfilled we can mark the view
      # as all lights green
      if tokenPermissionItem.tokenCriteriaMet:
          allTokenRequirementsMet = true

      tokenPermissionsItems.add(tokenPermissionItem)

  self.view.tokenPermissionsModel().setItems(tokenPermissionsItems)
  self.view.setAllTokenRequirementsMet(allTokenRequirementsMet)
  self.view.setRequiresTokenPermissionToJoin(tokenPermissionsItems.len > 0)

proc initCommunityTokenPermissionsModel(self: Module) =
  self.rebuildCommunityTokenPermissionsModel()

proc buildTokenList(self: Module) =
  var tokenListItems: seq[TokenListItem]
  var collectiblesListItems: seq[TokenListItem]

  let community = self.controller.getMyCommunity()
  let erc20Tokens = self.controller.getTokenList()

  for token in erc20Tokens:
    let tokenListItem = initTokenListItem(
      key = token.symbol,
      name = token.name,
      symbol = token.symbol,
      color = token.color,
      image = "",
      category = ord(TokenListItemCategory.General)
    )

    tokenListItems.add(tokenListItem)

  for token in community.communityTokensMetadata:
    let tokenListItem = initTokenListItem(
      key = token.symbol,
      name = token.name,
      symbol = token.symbol,
      color = "", # community tokens don't have `color`
      image = token.image,
      category = ord(TokenListItemCategory.Community)
    )
    collectiblesListItems.add(tokenListItem)

  self.view.setTokenListItems(tokenListItems)
  self.view.setCollectiblesListItems(collectiblesListItems)

method onWalletAccountTokensRebuilt*(self: Module) =
  self.rebuildCommunityTokenPermissionsModel()

method onOwnedcollectiblesUpdated*(self: Module) =
  self.rebuildCommunityTokenPermissionsModel()

proc convertPubKeysToJson(self: Module, pubKeys: string): seq[string] =
  return map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)

method initListOfMyContacts*(self: Module, pubKeys: string) =
  var myContacts: seq[UserItem]
  let contacts =  self.controller.getContacts(ContactsGroup.MyMutualContacts)
  for c in contacts:
    let item = self.createItemFromPublicKey(c.id)
    myContacts.add(item)

  self.view.listOfMyContacts().addItems(myContacts)

method clearListOfMyContacts*(self: Module) =
  self.view.listOfMyContacts().clear()


method load*(
    self: Module,
    channelGroup: ChannelGroupDto,
    events: EventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service) =
  self.controller.init()
  self.view.load()

method onChatsLoaded*(
    self: Module,
    channelGroup: ChannelGroupDto,
    events: UniqueUUIDEventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
  ) =
  self.chatsLoaded = true
  self.buildChatSectionUI(channelGroup, events, settingsService, nodeConfigurationService,
    contactService, chatService, communityService, messageService, gifService, mailserversService)

  if(not self.controller.isCommunity()):
    # we do this only in case of chat section (not in case of communities)
    self.initContactRequestsModel()
  else:
    self.usersModule.load()
    let community = self.controller.getMyCommunity()
    self.view.setAmIMember(community.joined)
    self.initCommunityTokenPermissionsModel()

  let activeChatId = self.controller.getActiveChatId()
  let isCurrentSectionActive = self.controller.getIsCurrentSectionActive()
  for chatId, cModule in self.chatContentModules:
    if isCurrentSectionActive and chatId == activeChatId:
      cModule.onMadeActive()

  self.view.chatsLoaded()

proc checkIfModuleDidLoad(self: Module) =
  if self.moduleLoaded:
    return

  for cModule in self.chatContentModules.values:
    if(not cModule.isLoaded()):
      return

  self.moduleLoaded = true
  if(self.controller.isCommunity()):
    self.delegate.communitySectionDidLoad()
  else:
    self.delegate.chatSectionDidLoad()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method chatContentDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method setActiveItem*(self: Module, itemId: string) =
  self.controller.setActiveItem(itemId)

method makeChatWithIdActive*(self: Module, chatId: string) =
  self.setActiveItem(chatId)
  singletonInstance.localAccountSensitiveSettings.setSectionLastOpenChat(self.controller.getMySectionId(), chatId)

proc updateActiveChatMembership*(self: Module) =
  let activeChatId = self.controller.getActiveChatId()
  let chat = self.controller.getChatDetails(activeChatId)

  if chat.chatType == ChatType.PrivateGroupChat:
    let amIMember = any(chat.members, proc (member: ChatMember): bool = member.id == singletonInstance.userProfile.getPubKey())
    self.view.setAmIMember(amIMember)

method activeItemSet*(self: Module, itemId: string) =
  let mySectionId = self.controller.getMySectionId()
  if (itemId == ""):
    self.view.activeItem().resetActiveItemData()
    singletonInstance.localAccountSensitiveSettings.removeSectionChatRecord(mySectionId)
    return

  let chat_item = self.view.chatsModel().getItemById(itemId)
  if(chat_item.isNil):
    # Should never be here
    error "chat-view unexisting item id: ", itemId, methodName="activeItemSet"
    return

  # update view maintained by this module
  self.view.chatsModel().setActiveItem(itemId)
  self.view.activeItemSet(chat_item)

  self.updateActiveChatMembership()

  let activeChatId = self.controller.getActiveChatId()

  # # update child modules
  for chatId, chatContentModule in self.chatContentModules:
    if chatId == activeChatId:
      chatContentModule.onMadeActive()
    else:
      chatContentModule.onMadeInactive()

  # save last open chat in settings for restore on the next app launch
  singletonInstance.localAccountSensitiveSettings.setSectionLastOpenChat(mySectionId, activeChatId)
  
  let (deactivateSectionId, deactivateChatId) = singletonInstance.loaderDeactivator.addChatInMemory(mySectionId, activeChatId)

  # notify parent module about active chat/channel
  self.delegate.onActiveChatChange(mySectionId, activeChatId)
  self.delegate.onDeactivateChatLoader(deactivateSectionId, deactivateChatId)

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getChatContentModule*(self: Module, chatId: string): QVariant =
  if(not self.chatContentModules.contains(chatId)):
    error "unexisting chat key: ", chatId, methodName="getChatContentModule"
    return

  return self.chatContentModules[chatId].getModuleAsVariant()

proc updateParentBadgeNotifications(self: Module) =
  let (unviewedMessagesCount, unviewedMentionsCount) = self.controller.sectionUnreadMessagesAndMentionsCount(
    self.controller.getMySectionId()
  )
  self.delegate.onNotificationsUpdated(
    self.controller.getMySectionId(),
    unviewedMessagesCount > 0,
    unviewedMentionsCount
  )

proc updateBadgeNotifications(self: Module, chat: ChatDto, hasUnreadMessages: bool, unviewedMentionsCount: int) =
  let chatId = chat.id

  if self.chatsLoaded:
    # update model of this module (appropriate chat from the chats list (chats model))
    self.view.chatsModel().updateNotificationsForItemById(chatId, hasUnreadMessages, unviewedMentionsCount)
    # update child module
    if (self.chatContentModules.contains(chatId)):
      self.chatContentModules[chatId].onNotificationsUpdated(hasUnreadMessages, unviewedMentionsCount)
    # Update category
    if chat.categoryId != "":
      let hasUnreadMessages = self.controller.chatsWithCategoryHaveUnreadMessages(chat.communityId, chat.categoryId)
      self.view.chatsModel().setCategoryHasUnreadMessages(chat.categoryId, hasUnreadMessages)

  # update parent module
  self.updateParentBadgeNotifications()

method updateLastMessageTimestamp*(self: Module, chatId: string, lastMessageTimestamp: int) =
  self.view.chatsModel().updateLastMessageTimestampOnItemById(chatId, lastMessageTimestamp)

method onActiveSectionChange*(self: Module, sectionId: string) =
  if(sectionId != self.controller.getMySectionId()):
    self.controller.setIsCurrentSectionActive(false)
    return

  if not self.view.getChatsLoaded:
    self.controller.getChatsAndBuildUI()

  self.controller.setIsCurrentSectionActive(true)
  let activeChatId = self.controller.getActiveChatId()
  if activeChatId == "":
    self.setFirstChannelAsActive()
  else:
    self.setActiveItem(activeChatId)
  self.delegate.onActiveChatChange(self.controller.getMySectionId(), self.controller.getActiveChatId())

method chatsModel*(self: Module): chats_model.Model =
  return self.view.chatsModel()

method addNewChat*(
    self: Module,
    chatDto: ChatDto,
    channelGroup: ChannelGroupDto,
    belongsToCommunity: bool,
    events: EventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    setChatAsActive: bool = true,
    insertIntoModel: bool = true,
  ): Item =
  let hasNotification = not chatDto.muted and (chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0)
  let notificationsCount = chatDto.unviewedMentionsCount

  var chatName = chatDto.name
  var chatImage = chatDto.icon
  var blocked = false
  var colorHash: ColorHashDto = @[]
  var colorId: int = 0
  var onlineStatus = OnlineStatus.Inactive
  var categoryPosition = -1

  var isUsersListAvailable = true
  if chatDto.chatType == ChatType.OneToOne:
    let contactDetails = self.controller.getContactDetails(chatDto.id)
    chatName = contactDetails.defaultDisplayName
    chatImage = contactDetails.icon
    blocked = contactDetails.details.isBlocked()
    isUsersListAvailable = false
    colorHash = self.controller.getColorHash(chatDto.id)
    colorId = self.controller.getColorId(chatDto.id)
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(chatDto.id).statusType)

  elif chatDto.chatType == ChatType.PrivateGroupChat:
    chatImage = chatDto.icon

  var amIChatAdmin = self.amIMarkedAsAdminUser(chatDto.members)
  if not amIChatAdmin and len(chatDto.communityId) != 0:
    let community = communityService.getCommunityById(chatDto.communityId)
    amIChatAdmin = amIChatAdmin or community.admin
  if chatDto.chatType != ChatType.PrivateGroupChat:
    amIChatAdmin = amIChatAdmin or channelGroup.admin

  var categoryOpened = true
  if chatDto.categoryId != "":
    let categoryItem = self.view.chatsModel.getItemById(chatDto.categoryId)
    categoryOpened = categoryItem.categoryOpened
    if channelGroup.id != "":
      for category in channelGroup.categories:
        if category.id == chatDto.categoryId:
          categoryPosition = category.position
          break
    else:
      let category = self.controller.getCommunityCategoryDetails(self.controller.getMySectionId(), chatDto.categoryId)
      if category.id == "":
        error "No category found for chat", chatName=chatDto.name, categoryId=chatDto.categoryId
      else:
        categoryPosition = category.position

  result = chat_item.initItem(
    chatDto.id,
    chatName,
    chatImage,
    chatDto.color,
    chatDto.emoji,
    chatDto.description,
    ChatType(chatDto.chatType).int,
    amIChatAdmin,
    chatDto.timestamp.int,
    hasNotification,
    notificationsCount,
    chatDto.muted,
    blocked,
    setChatAsActive,
    chatDto.position,
    chatDto.categoryId,
    categoryPosition,
    colorId,
    colorHash,
    chatDto.highlight,
    categoryOpened,
    onlineStatus = onlineStatus,
    loaderActive = setChatAsActive,
  )
  self.addSubmodule(
    chatDto.id,
    belongsToCommunity,
    isUsersListAvailable,
    events,
    settingsService,
    nodeConfigurationService,
    contactService,
    chatService,
    communityService,
    messageService,
    gifService,
    mailserversService,
  )
  self.chatContentModules[chatDto.id].load(result)
  if insertIntoModel:
    self.view.chatsModel().appendItem(result)
  if setChatAsActive:
    self.setActiveItem(result.id)

method switchToChannel*(self: Module, channelName: string) =
  if(not self.controller.isCommunity()):
    return
  let chats = self.controller.getAllChats(self.controller.getMySectionId())
  for c in chats:
    if c.name == channelName:
      self.setActiveItem(c.id)
      return

method doesCatOrChatExist*(self: Module, id: string): bool =
  return self.view.chatsModel().isItemWithIdAdded(id)

method doesTopLevelChatExist*(self: Module, chatId: string): bool =
  return self.view.chatsModel().isItemWithIdAdded(chatId)

method removeCommunityChat*(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.controller.removeCommunityChat(chatId)

method onCommunityCategoryEdited*(self: Module, cat: Category, chats: seq[ChatDto]) =
  # Update category itself
  self.view.chatsModel().updateCategoryDetailsById(
    cat.id,
    cat.name,
    cat.position
  )
  # Update chat items that have that category
  self.view.chatsModel().updateItemsWithCategoryDetailsById(
    chats,
    cat.id,
    cat.position,
  )

method onCommunityCategoryCreated*(self: Module, cat: Category, chats: seq[ChatDto], communityId: string) =
  if (self.doesCatOrChatExist(cat.id)):
    return

  # TODO get admin status
  discard self.addCategoryItem(cat, false, communityId)
  # Update chat items that now belong to that category
  self.view.chatsModel().updateItemsWithCategoryDetailsById(
    chats,
    cat.id,
    cat.position,
  )

method onCommunityCategoryDeleted*(self: Module, cat: Category, chats: seq[ChatDto]) =
  self.view.chatsModel().removeCategory(cat.id, chats)

method setFirstChannelAsActive*(self: Module) =
  if(self.view.chatsModel().getCount() == 0):
    self.setActiveItem("")
    return

  let chat_items = self.view.chatsModel().items()
  for chat_item in chat_items:
    if chat_item.`type` != CATEGORY_TYPE:
      self.setActiveItem(chat_item.id)
      break    

method onReorderChat*(self: Module, updatedChat: ChatDto) =
  self.view.chatsModel().reorderChats(@[updatedChat])

method onReorderChats*(self: Module, updatedChats: seq[ChatDto]) =
  self.view.chatsModel().reorderChats(updatedChats)

method onReorderCategory*(self: Module, catId: string, position: int) =
  self.view.chatsModel().reorderCategoryById(catId, position)

method onCategoryNameChanged*(self: Module, category: Category) =
  self.view.chatsModel().renameCategory(category.id, category.name)

method onCommunityChannelDeletedOrChatLeft*(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.view.chatsModel().removeItemById(chatId)
  self.removeSubmodule(chatId)

  self.setFirstChannelAsActive()

method onCommunityChannelEdited*(self: Module, chat: ChatDto) =
  if(not self.chatContentModules.contains(chat.id)):
    return
  self.view.chatsModel().updateItemDetailsById(chat.id, chat.name, chat.description, chat.emoji, chat.color)

method switchToOrCreateOneToOneChat*(self: Module, chatId: string) =
  # One To One chat is available only in the `Chat` section
  if (self.controller.getMySectionId() != singletonInstance.userProfile.getPubKey()):
    return

  if (self.delegate.getActiveSectionId() != self.controller.getMySectionId()):
    self.delegate.setActiveSectionById(self.controller.getMySectionId())

  if(self.chatContentModules.hasKey(chatId)):
    self.setActiveItem(chatId)
    return

  self.controller.createOneToOneChat("", chatId, "")

method createOneToOneChat*(self: Module, communityID: string, chatId: string, ensName: string) =
  if(self.controller.isCommunity()):
     # initiate chat creation in the `Chat` seciton module.
     self.controller.switchToOrCreateOneToOneChat(chatId, ensName)
     return

  # Adding this call here we have the same as we had before (didn't inspect what are all cases when this
  # `createOneToOneChat` is called), but I am sure that after checking all cases and inspecting them, this can be improved.
  self.switchToOrCreateOneToOneChat(chatId)

method leaveChat*(self: Module, chatId: string) =
  self.controller.leaveChat(chatId)

method muteChat*(self: Module, chatId: string) =
  self.controller.muteChat(chatId)

method unmuteChat*(self: Module, chatId: string) =
  self.controller.unmuteChat(chatId)

method muteCategory*(self: Module, categoryId: string) =
  self.controller.muteCategory(categoryId)

method unmuteCategory*(self: Module, categoryId: string) =
  self.controller.unmuteCategory(categoryId)

method onCategoryMuted*(self: Module, categoryId: string) =
  self.view.chatsModel().changeMutedOnItemByCategoryId(categoryId, true)

method onCategoryUnmuted*(self: Module, categoryId: string) =
  self.view.chatsModel().changeMutedOnItemByCategoryId(categoryId, false)

method onChatMuted*(self: Module, chatId: string) =
  self.view.chatsModel().changeMutedOnItemById(chatId, muted=true)

method onChatUnmuted*(self: Module, chatId: string) =
  self.view.chatsModel().changeMutedOnItemById(chatId, muted=false)

method onCommunityTokenPermissionDeleted*(self: Module, communityId: string, permissionId: string) =
  self.rebuildCommunityTokenPermissionsModel()
  singletonInstance.globalEvents.showCommunityTokenPermissionDeletedNotification(communityId, "Community permission deleted", "A token permission has been removed")

method onCommunityTokenPermissionCreated*(self: Module, communityId: string, tokenPermission: CommunityTokenPermissionDto) =
  if tokenPermission.`type` == TokenPermissionType.BecomeMember:
    let tokenPermissionItem = self.buildTokenPermissionItem(tokenPermission)

    if tokenPermissionItem.tokenCriteriaMet:
      self.view.setAllTokenRequirementsMet(true)

    self.view.tokenPermissionsModel.addItem(tokenPermissionItem)
    self.view.setRequiresTokenPermissionToJoin(true)
  singletonInstance.globalEvents.showCommunityTokenPermissionCreatedNotification(communityId, "Community permission created", "A token permission has been added")

method onCommunityTokenPermissionUpdated*(self: Module, communityId: string, tokenPermission: CommunityTokenPermissionDto) =
  if tokenPermission.`type` == TokenPermissionType.BecomeMember:
    let tokenPermissionItem = self.buildTokenPermissionItem(tokenPermission)
    self.view.tokenPermissionsModel.updateItem(tokenPermission.id, tokenPermissionItem)
    if tokenPermissionItem.tokenCriteriaMet:
      self.view.setAllTokenRequirementsMet(true)
      return

    # we now need to check whether any other permission criteria where met.
    let community = self.controller.getMyCommunity()
    for id, permission in community.tokenPermissions:
      if id != tokenPermission.id:
        for tc in permission.tokenCriteria:
          let balance = self.controller.allAccountsTokenBalance(tc.symbol)
          let amount = tc.amount.parseFloat
          let tokenCriteriaMet = balance >= amount
          if tokenCriteriaMet:
            return

    self.view.setAllTokenRequirementsMet(false)
  singletonInstance.globalEvents.showCommunityTokenPermissionUpdatedNotification(communityId, "Community permission updated", "A token permission has been updated")

method onCommunityTokenPermissionCreationFailed*(self: Module, communityId: string) =
  singletonInstance.globalEvents.showCommunityTokenPermissionCreationFailedNotification(communityId, "Failed to create community permission", "Something went wrong")

method onCommunityTokenPermissionUpdateFailed*(self: Module, communityId: string) =
  singletonInstance.globalEvents.showCommunityTokenPermissionUpdateFailedNotification(communityId, "Failed to update community permission", "Something went wrong")

method onCommunityTokenPermissionDeletionFailed*(self: Module, communityId: string) =
  singletonInstance.globalEvents.showCommunityTokenPermissionDeletionFailedNotification(communityId, "Failed to delete community permission", "Something went wrong")

method onCommunityTokenMetadataAdded*(self: Module, communityId: string, tokenMetadata: CommunityTokensMetadataDto) = 
  let tokenListItem = initTokenListItem(
    key = tokenMetadata.symbol,
    name = tokenMetadata.name,
    symbol = tokenMetadata.symbol,
    color = "", # tokenMetadata doesn't provide a color
    image = tokenMetadata.image,
    category = ord(TokenListItemCategory.Community)
  )

  if tokenMetadata.tokenType == community_dto.TokenType.ERC721 and not self.view.collectiblesListModel().hasItem(tokenMetadata.symbol):
    self.view.collectiblesListModel.addItems(@[tokenListItem])
    return

  if tokenMetadata.tokenType == community_dto.TokenType.ERC20 and not self.view.tokenListModel().hasItem(tokenMetadata.symbol):
    self.view.tokenListModel.addItems(@[tokenListItem])

method onKickedFromCommunity*(self: Module) =
  self.view.setAmIMember(false)

method onJoinedCommunity*(self: Module) =
  self.view.setAmIMember(true)

method onUserAuthenticated*(self: Module, pin: string, password: string, keyUid: string) =
  self.controller.requestToJoinCommunityAuthenticated(password)

method onMarkAllMessagesRead*(self: Module, chat: ChatDto) =
  self.updateBadgeNotifications(chat, hasUnreadMessages=false, unviewedMentionsCount=0)

method markAllMessagesRead*(self: Module, chatId: string) =
  self.controller.markAllMessagesRead(chatId)

method clearChatHistory*(self: Module, chatId: string) =
  self.controller.clearChatHistory(chatId)

method getCurrentFleet*(self: Module): string =
  return self.controller.getCurrentFleet()

method acceptContactRequest*(self: Module, publicKey: string, contactRequestId: string) =
  self.controller.acceptContactRequest(publicKey, contactRequestId)

method onContactAdded*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemById(publicKey)

  let contact = self.controller.getContactById(publicKey)
  if (contact.isContact):
    self.switchToOrCreateOneToOneChat(publicKey)

method acceptAllContactRequests*(self: Module) =
  let pubKeys = self.view.contactRequestsModel().getItemIds()
  for pk in pubKeys:
    self.acceptContactRequest(pk, "")

method dismissContactRequest*(self: Module, publicKey: string, contactRequestId: string) =
  self.controller.dismissContactRequest(publicKey, contactRequestId)

method onContactRejected*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemById(publicKey)

method dismissAllContactRequests*(self: Module) =
  let pubKeys = self.view.contactRequestsModel().getItemIds()
  for pk in pubKeys:
    self.dismissContactRequest(pk, "")

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method onContactBlocked*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemById(publicKey)
  self.view.chatsModel().changeBlockedOnItemById(publicKey, blocked=true)

method onContactUnblocked*(self: Module, publicKey: string) =
  self.view.chatsModel().changeBlockedOnItemById(publicKey, blocked=false)
  self.onContactDetailsUpdated(publicKey)

method onContactDetailsUpdated*(self: Module, publicKey: string) =
  if(self.controller.isCommunity()):
    return
  let contactDetails = self.controller.getContactDetails(publicKey)
  if (contactDetails.details.isContactRequestReceived() and
    not contactDetails.details.isContactRequestSent() and
    not contactDetails.details.isBlocked() and
    not self.view.contactRequestsModel().isContactWithIdAdded(publicKey)):
      let item = self.createItemFromPublicKey(publicKey)
      self.view.contactRequestsModel().addItem(item)
      singletonInstance.globalEvents.showNewContactRequestNotification("New Contact Request",
      fmt "{contactDetails.defaultDisplayName} added you as contact",
        singletonInstance.userProfile.getPubKey())

  let chatName = contactDetails.defaultDisplayName
  let chatImage = contactDetails.icon
  let trustStatus = contactDetails.details.trustStatus
  self.view.chatsModel().updateItemDetailsById(publicKey, chatName, chatImage, trustStatus)

method onNewMessagesReceived*(self: Module, sectionIdMsgBelongsTo: string, chatIdMsgBelongsTo: string,
    chatTypeMsgBelongsTo: ChatType, lastMessageTimestamp: int, unviewedMessagesCount: int, unviewedMentionsCount: int,
    message: MessageDto) =
  self.updateLastMessageTimestamp(chatIdMsgBelongsTo, lastMessageTimestamp)

  # Any type of message coming from ourselves should never be shown as notification
  # and no need in badge notification update
  let myPK = singletonInstance.userProfile.getPubKey()
  if myPK == message.from:
    return

  let chatDetails = self.controller.getChatDetails(chatIdMsgBelongsTo)

  if (chatDetails.muted):
    # No need to send a notification
    return

  if chatDetails.categoryId != "":
    self.view.chatsModel().setCategoryHasUnreadMessages(chatDetails.categoryId, true)

  # Prepare notification
  var notificationType = notification_details.NotificationType.NewMessage
  if(message.isPersonalMention(myPK)):
    notificationType = notification_details.NotificationType.NewMessageWithPersonalMention
  elif(message.isGlobalMention()):
    notificationType = notification_details.NotificationType.NewMessageWithGlobalMention

  let contactDetails = self.controller.getContactDetails(message.`from`)
  let communityChats = self.controller.getCommunityById(chatDetails.communityId).chats
  let renderedMessageText = self.controller.getRenderedText(message.parsedText, communityChats)
  var plainText = singletonInstance.utils.plainText(renderedMessageText)
  if message.contentType == ContentType.Sticker or (message.contentType == ContentType.Image and len(plainText) == 0):
    plainText = "🖼️"
  var notificationTitle = contactDetails.defaultDisplayName

  case chatDetails.chatType:
    of ChatType.PrivateGroupChat:
      notificationTitle.add(fmt" ({chatDetails.name})")
    of ChatType.CommunityChat:
      if (chatDetails.categoryId.len == 0):
        notificationTitle.add(fmt" (#{chatDetails.name})")
      else:
        let categoryDetails = self.controller.getCommunityCategoryDetails(chatDetails.communityId, chatDetails.categoryId)
        notificationTitle.add(fmt" (#{chatDetails.name}, {categoryDetails.name})")
    else:
      discard

  let messageBelongsToActiveSection = sectionIdMsgBelongsTo == self.controller.getMySectionId() and
    self.controller.getMySectionId() == self.delegate.getActiveSectionId()
  let messageBelongsToActiveChat = self.controller.getActiveChatId() == chatIdMsgBelongsTo

  singletonInstance.globalEvents.showMessageNotification(notificationTitle, plainText, sectionIdMsgBelongsTo,
    self.controller.isCommunity(), messageBelongsToActiveSection, chatIdMsgBelongsTo, messageBelongsToActiveChat,
    message.id, notificationType.int, chatTypeMsgBelongsTo == ChatType.OneToOne,
    chatTypeMsgBelongsTo == ChatType.PrivateGroupChat)

method addGroupMembers*(self: Module, chatId: string, pubKeys: string) =
  self.controller.addGroupMembers(chatId, self.convertPubKeysToJson(pubKeys))

method removeMemberFromGroupChat*(self: Module, communityID: string, chatId: string, pubKey: string) =
  self.controller.removeMemberFromGroupChat(communityID, chatId, pubKey)

method removeMembersFromGroupChat*(self: Module, communityID: string, chatId: string, pubKeys: string) =
  self.controller.removeMembersFromGroupChat(communityID, chatId, self.convertPubKeysToJson(pubKeys))

method renameGroupChat*(self: Module, chatId: string, newName: string) =
  self.controller.renameGroupChat(chatId, newName)

method updateGroupChatDetails*(self: Module, chatId: string, newGroupName: string, newGroupColor: string, newGroupImageJson: string) =
  self.controller.updateGroupChatDetails(chatId, newGroupName, newGroupColor, newGroupImageJson)

method makeAdmin*(self: Module, communityID: string, chatId: string, pubKey: string) =
  self.controller.makeAdmin(communityID, chatId, pubKey)

method createGroupChat*(self: Module, communityID: string, groupName: string, pubKeys: string) =
  self.controller.createGroupChat(communityID, groupName, self.convertPubKeysToJson(pubKeys))

method createGroupChat*(self: Module, groupName: string, pubKeys: seq[string]) =
  self.controller.createGroupChat("", groupName, pubKeys)

method joinGroupChatFromInvitation*(self: Module, groupName: string, chatId: string, adminPK: string) =
  self.controller.joinGroupChatFromInvitation(groupName, chatId, adminPK)

method onChatRenamed*(self: Module, chatId: string, newName: string) =
  self.view.chatsModel().renameItemById(chatId, newName)

method onGroupChatDetailsUpdated*(self: Module, chatId, newName, newColor, newImage: string) =
  self.view.chatsModel().updateNameColorIconOnItemById(chatId, newName, newColor, newImage)

method acceptRequestToJoinCommunity*(self: Module, requestId: string, communityId: string) =
  self.controller.acceptRequestToJoinCommunity(requestId, communityId)

method declineRequestToJoinCommunity*(self: Module, requestId: string, communityId: string) =
  self.controller.declineRequestToJoinCommunity(requestId, communityId)

method onAcceptRequestToJoinFailedNoPermission*(self: Module, communityId: string, memberKey: string, requestId: string) =
  let community = self.controller.getCommunityById(communityId)
  let contact = self.controller.getContactById(memberKey)
  self.view.emitOpenNoPermissionsToJoinPopupSignal(community.name, contact.displayName,  community.id, requestId)

method createCommunityChannel*(self: Module, name, description, emoji, color, categoryId: string) =
  self.controller.createCommunityChannel(name, description, emoji, color, categoryId)

method editCommunityChannel*(self: Module, channelId, name, description, emoji, color,
    categoryId: string, position: int) =
  self.controller.editCommunityChannel(channelId, name, description, emoji, color, categoryId,
    position)

method createCommunityCategory*(self: Module, name: string, channels: seq[string]) =
  self.controller.createCommunityCategory(name, channels)

method editCommunityCategory*(self: Module, categoryId: string, name: string, channels: seq[string]) =
  self.controller.editCommunityCategory(categoryId, name, channels)

method deleteCommunityCategory*(self: Module, categoryId: string) =
  self.controller.deleteCommunityCategory(categoryId)

method leaveCommunity*(self: Module) =
  self.controller.leaveCommunity()

method removeUserFromCommunity*(self: Module, pubKey: string) =
  self.controller.removeUserFromCommunity(pubKey)

method banUserFromCommunity*(self: Module, pubKey: string) =
  self.controller.banUserFromCommunity(pubkey)

method unbanUserFromCommunity*(self: Module, pubKey: string) =
  self.controller.unbanUserFromCommunity(pubkey)

method editCommunity*(self: Module, name: string,
                        description, introMessage, outroMessage: string,
                        access: int, color: string, tags: string,
                        logoJsonStr: string,
                        bannerJsonStr: string,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool) =
  self.controller.editCommunity(name, description, introMessage, outroMessage, access, color, tags, logoJsonStr,
                                bannerJsonStr, historyArchiveSupportEnabled, pinMessageAllMembersEnabled)

method exportCommunity*(self: Module): string =
  self.controller.exportCommunity()

method setCommunityMuted*(self: Module, muted: bool) =
  self.controller.setCommunityMuted(muted)

method inviteUsersToCommunity*(self: Module, pubKeysJSON: string, inviteMessage: string): string =
  result = self.controller.inviteUsersToCommunity(pubKeysJSON, inviteMessage)

method prepareEditCategoryModel*(self: Module, categoryId: string) =
  self.view.editCategoryChannelsModel().clearItems()
  let communityId = self.controller.getMySectionId()
  let chats = self.controller.getChats(communityId, categoryId="")
  for chat in chats:
    let c = self.controller.getChatDetails(chat.id)
    let chatItem = chat_item.initItem(
      c.id,
      c.name,
      icon="",
      c.color,
      c.emoji,
      c.description,
      c.chatType.int,
      amIChatAdmin=false,
      lastMessageTimestamp=(-1),
      hasUnreadMessages=false,
      notificationsCount=0,
      c.muted,
      blocked=false,
      active=false,
      c.position,
      categoryId="",
    )
    self.view.editCategoryChannelsModel().appendItem(chatItem)
  let catChats = self.controller.getChats(communityId, categoryId)
  for chat in catChats:
    let c = self.controller.getChatDetails(chat.id)
    let chatItem = chat_item.initItem(
      c.id,
      c.name,
      icon="",
      c.color,
      c.emoji,
      c.description,
      c.chatType.int,
      amIChatAdmin=false,
      lastMessageTimestamp=(-1),
      hasUnreadMessages=false,
      notificationsCount=0,
      c.muted,
      blocked=false,
      active=false,
      c.position,
      categoryId,
    )
    self.view.editCategoryChannelsModel().appendItem(chatItem, ignoreCategory = true)

method reorderCommunityCategories*(self: Module, categoryId: string, categoryPosition: int) =
  var finalPosition = categoryPosition
  if finalPosition < 0:
    finalPosition = 0

  self.controller.reorderCommunityCategories(categoryId, finalPosition)

method reorderCommunityChat*(self: Module, categoryId: string, chatId: string, toPosition: int) =
  self.controller.reorderCommunityChat(categoryId, chatId, toPosition + 1)

method setLoadingHistoryMessagesInProgress*(self: Module, isLoading: bool) =
  self.view.setLoadingHistoryMessagesInProgress(isLoading)

proc addOrUpdateChat(self: Module,
    chat: ChatDto,
    channelGroup: ChannelGroupDto,
    belongsToCommunity: bool,
    events: UniqueUUIDEventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    setChatAsActive: bool = true,
    insertIntoModel: bool = true,
  ): Item =

  let sectionId = self.controller.getMySectionId()
  if(belongsToCommunity and sectionId != chat.communityId or
    not belongsToCommunity and sectionId != singletonInstance.userProfile.getPubKey()):
    return

  let chatExists = self.doesCatOrChatExist(chat.id)

  if not self.chatsLoaded or chatExists:
    # Update badges
    var hasUnreadMessages = false
    if not chat.muted:
      hasUnreadMessages = chat.unviewedMessagesCount > 0
    self.updateBadgeNotifications(chat, hasUnreadMessages, chat.unviewedMentionsCount)

  if not self.chatsLoaded:
    return

  let activeChatId = self.controller.getActiveChatId()
  if chat.id == activeChatId:
    self.updateActiveChatMembership()

  if chatExists:
    if (chat.chatType == ChatType.PrivateGroupChat):
      self.onGroupChatDetailsUpdated(chat.id, chat.name, chat.color, chat.icon)
    elif (chat.chatType != ChatType.OneToOne):
      self.onChatRenamed(chat.id, chat.name)
    return

  result = self.addNewChat(
      chat,
      channelGroup,
      belongsToCommunity,
      events.eventsEmitter(),
      settingsService,
      nodeConfigurationService,
      contactService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService,
      setChatAsActive,
      insertIntoModel,
    )

method addOrUpdateChat*(self: Module,
    chat: ChatDto,
    belongsToCommunity: bool,
    events: UniqueUUIDEventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    setChatAsActive: bool = true,
    insertIntoModel: bool = true,
  ): Item =
 result = self.addOrUpdateChat(
    chat,
    ChannelGroupDto(),
    belongsToCommunity,
    events,
    settingsService,
    nodeConfigurationService,
    contactService,
    chatService,
    communityService,
    messageService,
    gifService,
    mailserversService,
    setChatAsActive,
    insertIntoModel,
  )

method downloadMessages*(self: Module, chatId: string, filePath: string) =
  if(not self.chatContentModules.contains(chatId)):
    error "unexisting chat key: ", chatId, methodName="downloadMessages"
    return

  self.chatContentModules[chatId].downloadMessages(filePath)

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    let status = toOnlineStatus(s.statusType)
    self.view.chatsModel().updateItemOnlineStatusById(s.publicKey, status)

method joinSpectatedCommunity*(self: Module) =
  if self.usersModule != nil:
    self.usersModule.updateMembersList()

method createOrEditCommunityTokenPermission*(self: Module, communityId: string, permissionId: string, permissionType: int, tokenCriteriaJson: string, isPrivate: bool) =
  var tokenPermission = CommunityTokenPermissionDto()
  tokenPermission.id = permissionId
  tokenPermission.isPrivate = isPrivate
  tokenPermission.`type` = TokenPermissionType(permissionType)

  let tokenCriteriaJsonObj = tokenCriteriaJson.parseJson
  for tokenCriteria in tokenCriteriaJsonObj:

    let viewAmount = tokenCriteria{"amount"}.getFloat
    var tokenCriteriaDto = tokenCriteria.toTokenCriteriaDto
    if tokenCriteriaDto.`type` == community_dto.TokenType.ERC20:
      tokenCriteriaDto.decimals = self.controller.getTokenDecimals(tokenCriteriaDto.symbol)

    let contractAddresses = self.controller.getContractAddressesForToken(tokenCriteriaDto.symbol)
    if contractAddresses.len == 0 and tokenCriteriaDto.`type` != community_dto.TokenType.ENS:
      if permissionId == "":
        self.onCommunityTokenPermissionCreationFailed(communityId)
        return 
      self.onCommunityTokenPermissionUpdateFailed(communityId)
      return

    tokenCriteriaDto.amount = viewAmount.formatBiggestFloat(ffDecimal)
    tokenCriteriaDto.contractAddresses = contractAddresses
    tokenPermission.tokenCriteria.add(tokenCriteriaDto)
  
  self.controller.createOrEditCommunityTokenPermission(communityId, tokenPermission)

method deleteCommunityTokenPermission*(self: Module, communityId: string, permissionId: string) =
  self.controller.deleteCommunityTokenPermission(communityId, permissionId)

method requestToJoinCommunity*(self: Module, communityId: string, ensName: string) =
  self.controller.requestToJoinCommunity(communityId, ensName)

method requestToJoinCommunityWithAuthentication*(self: Module, communityId: string, ensName: string) =
  self.controller.authenticateToRequestToJoinCommunity(communityId, ensName)

proc buildTokenPermissionItem*(self: Module, tokenPermission: CommunityTokenPermissionDto): TokenPermissionItem =
  var tokenCriteriaItems: seq[TokenCriteriaItem] = @[]
  var allTokenCriteriaMet = true

  for tc in tokenPermission.tokenCriteria:

    var tokenCriteriaMet = false
    let amount = tc.amount.parseFloat

    if tc.`type` == TokenType.ERC20:
      let balance = self.controller.allAccountsTokenBalance(tc.symbol)
      tokenCriteriaMet = balance >= amount

    if tc.`type` == TokenType.ERC721:
      for chainId, address in tc.contractAddresses:
        tokenCriteriaMet = self.controller.ownsCollectible(chainId, address, tc.tokenIds)
        if tokenCriteriaMet:
          break

    let tokenCriteriaItem = initTokenCriteriaItem(
      tc.symbol,
      tc.name,
      amount,
      tc.`type`.int,
      tc.ensPattern,
      tokenCriteriaMet
    )
    if not tokenCriteriaMet:
      allTokenCriteriaMet = false

    tokenCriteriaItems.add(tokenCriteriaItem)

  let tokenPermissionItem = initTokenPermissionItem(
      tokenPermission.id, 
      tokenPermission.`type`.int, 
      tokenCriteriaItems,
      @[], # TODO: handle chat list items
      tokenPermission.isPrivate,
      allTokenCriteriaMet
  )

  return tokenPermissionItem

method onDeactivateChatLoader*(self: Module, chatId: string) =
  self.view.chatsModel().disableChatLoader(chatId)

