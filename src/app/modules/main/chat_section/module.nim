import NimQml, Tables, chronicles, json, sequtils, strutils, strformat, sugar

import io_interface
import ../io_interface as delegate_interface
import view, controller, active_item
import model as chats_model
import item as chat_item
import ../../shared_models/user_item as user_item
import ../../shared_models/user_model as user_model

import chat_content/module as chat_content_module
import chat_content/users/module as users_module

import ../../../global/app_sections_config as conf
import ../../../global/global_singleton
import ../../../core/eventemitter
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
import ../../../../app_service/service/visual_identity/service as visual_identity
import ../../../../app_service/service/contacts/dto/contacts as contacts_dto

export io_interface

const CATEGORY_ID_PREFIX = "cat-"

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
    usersModule: users_module.AccessInterface

# Forward declaration
proc buildChatSectionUI(self: Module,
  channelGroup: ChannelGroupDto,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service)

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    sectionId: string,
    # channels: seq[ChatDto],
    isCommunity: bool,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service
  ): Module =
  result = Module()
  result.delegate = delegate
  result.controller = controller.newController(result, sectionId, isCommunity, events, settingsService, nodeConfigurationService,
  contactService, chatService, communityService, messageService, gifService, mailserversService)
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false

  result.chatContentModules = initOrderedTable[string, chat_content_module.AccessInterface]()

  # Simple community channels uses comminity usersModule while chats uses their own usersModule
  if isCommunity:
    result.usersModule = users_module.newModule(
      events, sectionId, chatId = "", belongsToCommunity = true, isUsersListAvailable = true,
      contactService, chat_service, communityService, messageService)

method delete*(self: Module) =
  for cModule in self.chatContentModules.values:
    cModule.delete
  self.chatContentModules.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
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


proc addEmptyChatItemForCategory(self: Module, category: Category) =
  # Add an empty chat item that has the category info
  let emptyChatItem = chat_item.initItem(
        id = CATEGORY_ID_PREFIX & category.id,
        name = "",
        icon = "",
        color = "",
        emoji = "",
        description = "",
        `type` = chat_item.CATEGORY_TYPE,
        amIChatAdmin = false,
        lastMessageTimestamp = 0,
        hasUnreadMessages = false,
        notificationsCount = 0,
        muted = false,
        blocked = false,
        active = false,
        position = 99,
        category.id,
        category.name,
        category.position,
      )
  self.view.chatsModel().appendItem(emptyChatItem)

proc buildChatSectionUI(
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
  var selectedItemId = ""
  let sectionLastOpenChat = singletonInstance.localAccountSensitiveSettings.getSectionLastOpenChat(self.controller.getMySectionId())

  # Keep a list of categories that have been associated correctly to a chat
  # If a category doesn't have a chat, we add it as an empty chat
  var categoriesWithAssociatedItems: seq[string] = @[]

  for chatDto in channelGroup.chats:
    let hasNotification = not chatDto.muted and (chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0)
    let notificationsCount = chatDto.unviewedMentionsCount

    var chatName = chatDto.name
    var chatImage = ""
    var colorHash: ColorHashDto = @[]
    var colorId: int = 0
    var onlineStatus = OnlineStatus.Inactive
    let isUsersListAvailable = chatDto.chatType != ChatType.OneToOne
    var blocked = false
    let belongToCommunity = chatDto.communityId != ""
    var categoryName = ""
    var categoryPosition = -1
    var chatPosition = chatDto.position

    if chatDto.chatType == ChatType.OneToOne:
      let contactDetails = self.controller.getContactDetails(chatDto.id)
      chatName = contactDetails.defaultDisplayName
      chatImage = contactDetails.icon
      blocked = contactDetails.details.isBlocked()
      colorHash = self.controller.getColorHash(chatDto.id)
      colorId = self.controller.getColorId(chatDto.id)
      onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(chatDto.id).statusType)

    elif chatDto.chatType == ChatType.PrivateGroupChat:
      chatImage = chatDto.icon

    # for group chats only member.admin should be checked,
    # because channelGroup.admin is alway true
    var amIChatAdmin = self.amIMarkedAsAdminUser(chatDto.members)
    if chatDto.chatType != ChatType.PrivateGroupChat:
      amIChatAdmin = amIChatAdmin or channelGroup.admin

      # Add an empty chat item that has the category info
    var isActive = false
    # restore on a startup last open channel for the section or
    # make the first channel which doesn't belong to any category active
    if selectedItemId.len == 0 or chatDto.id == sectionLastOpenChat:
      selectedItemId = chatDto.id
      isActive = true

    if chatDto.categoryId != "":
      for category in channelGroup.categories:
        if category.id == chatDto.categoryId:
          categoriesWithAssociatedItems.add(chatDto.categoryId)
          categoryName = category.name
          categoryPosition = category.position
          break
      if categoryName == "":
        error "No category found in the channel group for chat", chatName=chatDto.name, categoryId=chatDto.categoryId

    let newChatItem = chat_item.initItem(
      chatDto.id,
      chatName,
      chatImage,
      chatDto.color,
      chatDto.emoji,
      chatDto.description,
      chatDto.chatType.int,
      amIChatAdmin,
      chatDto.timestamp.int,
      hasNotification,
      notificationsCount,
      chatDto.muted,
      blocked,
      isActive,
      chatDto.position,
      chatDto.categoryId,
      categoryName,
      categoryPosition,
      colorId,
      colorHash,
      onlineStatus = onlineStatus,
    )

    self.view.chatsModel().appendItem(newChatItem)

    self.addSubmodule(
      chatDto.id,
      belongToCommunity,
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

  # Loop channelGroup categories to see if some of them don't have a chat
  if categoriesWithAssociatedItems.len < channelGroup.categories.len:
    for category in channelGroup.categories:
      var found = false
      for categoryId in categoriesWithAssociatedItems:
        if categoryId == category.id:
          found = true
          break
      if found:
        continue

      self.addEmptyChatItemForCategory(category)

  self.setActiveItem(selectedItemId)

proc createItemFromPublicKey(self: Module, publicKey: string): UserItem =
  let contactDetails = self.controller.getContactDetails(publicKey)

  return initUserItem(
    pubKey = contactDetails.details.id,
    displayName = contactDetails.details.displayName,
    ensName = contactDetails.details.name,
    localNickname = contactDetails.details.localNickname,
    alias = contactDetails.details.alias,
    icon = contactDetails.icon,
    colorId = contactDetails.colorId,
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

  self.buildChatSectionUI(channelGroup, events, settingsService, nodeConfigurationService,
    contactService, chatService, communityService, messageService, gifService, mailserversService)

  if(not self.controller.isCommunity()):
    # we do this only in case of chat section (not in case of communities)
    self.initContactRequestsModel()
  else:
    self.usersModule.load()

  let activeChatId = self.controller.getActiveChatId()
  for chatId, cModule in self.chatContentModules:
    cModule.load()
    if chatId == activeChatId:
      cModule.onMadeActive()

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

  let activeChatId = self.controller.getActiveChatId()

  # # update child modules
  for chatId, chatContentModule in self.chatContentModules:
    if chatId == activeChatId:
      chatContentModule.onMadeActive()
    else:
      chatContentModule.onMadeInactive()

  # save last open chat in settings for restore on the next app launch
  singletonInstance.localAccountSensitiveSettings.setSectionLastOpenChat(mySectionId, activeChatId)

  # notify parent module about active chat/channel
  self.delegate.onActiveChatChange(mySectionId, activeChatId)

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getChatContentModule*(self: Module, chatId: string): QVariant =
  if(not self.chatContentModules.contains(chatId)):
    error "unexisting chat key: ", chatId, methodName="getChatContentModule"
    return

  return self.chatContentModules[chatId].getModuleAsVariant()

proc updateParentBadgeNotifications(self: Module) =
  var (sectionHasUnreadMessages, sectionNotificationCount) = self.view.chatsModel().getAllNotifications()
  if(not self.controller.isCommunity()):
    sectionHasUnreadMessages = sectionHasUnreadMessages or sectionNotificationCount > 0
  self.delegate.onNotificationsUpdated(self.controller.getMySectionId(), sectionHasUnreadMessages, sectionNotificationCount)

proc updateBadgeNotifications(self: Module, chatId: string, hasUnreadMessages: bool, unviewedMentionsCount: int) =
  # update model of this module (appropriate chat from the chats list (chats model))
  self.view.chatsModel().updateNotificationsForItemById(chatId, hasUnreadMessages, unviewedMentionsCount)
  # update child module
  if (self.chatContentModules.contains(chatId)):
    self.chatContentModules[chatId].onNotificationsUpdated(hasUnreadMessages, unviewedMentionsCount)
  # update parent module
  self.updateParentBadgeNotifications()

method updateLastMessageTimestamp*(self: Module, chatId: string, lastMessageTimestamp: int) =
  self.view.chatsModel().updateLastMessageTimestampOnItemById(chatId, lastMessageTimestamp)

method onActiveSectionChange*(self: Module, sectionId: string) =
  if(sectionId != self.controller.getMySectionId()):
    return

  self.delegate.onActiveChatChange(self.controller.getMySectionId(), self.controller.getActiveChatId())

method chatsModel*(self: Module): chats_model.Model =
  return self.view.chatsModel()

method addNewChat*(
    self: Module,
    chatDto: ChatDto,
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
    setChatAsActive: bool = true) =
  let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
  let notificationsCount = chatDto.unviewedMentionsCount
  var chatName = chatDto.name
  var chatImage = chatDto.icon
  var colorHash: ColorHashDto = @[]
  var colorId: int = 0
  var onlineStatus = OnlineStatus.Inactive
  var categoryName = ""
  var categoryPosition = -1

  var isUsersListAvailable = true
  if(chatDto.chatType == ChatType.OneToOne):
    isUsersListAvailable = false
    (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(chatDto.id)
    colorHash = self.controller.getColorHash(chatDto.id)
    colorId = self.controller.getColorId(chatDto.id)
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(chatDto.id).statusType)

  var amIChatAdmin = false
  if(belongsToCommunity):
    amIChatAdmin = self.controller.getMyCommunity().admin
  else:
    amIChatAdmin = self.amIMarkedAsAdminUser(chatDto.members)

  if chatDto.categoryId != "":
    let category = self.controller.getCommunityCategoryDetails(self.controller.getMySectionId(), chatDto.categoryId)
    if category.id == "":
      error "No category found for chat", chatName=chatDto.name, categoryId=chatDto.categoryId
    else:
      categoryName = category.name
      categoryPosition = category.position

  let chat_item = chat_item.initItem(
    chatDto.id,
    chatName,
    chatImage,
    chatDto.color,
    chatDto.emoji,
    chatDto.description,
    chatDto.chatType.int,
    amIChatAdmin,
    chatDto.timestamp.int,
    hasNotification,
    notificationsCount,
    chatDto.muted,
    blocked=false,
    setChatAsActive,
    chatDto.position,
    chatDto.categoryId,
    categoryName,
    categoryPosition,
    colorId,
    colorHash,
    chatDto.highlight,
    onlineStatus = onlineStatus,
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
  self.chatContentModules[chatDto.id].load()
  self.view.chatsModel().appendItem(chat_item)
  if setChatAsActive:
    self.setActiveItem(chat_item.id)

method switchToChannel*(self: Module, channelName: string) =
  if(not self.controller.isCommunity()):
    return
  let chats = self.controller.getAllChats(self.controller.getMySectionId())
  for c in chats:
    if c.name == channelName:
      if c.categoryId == "":
        self.setActiveItem(c.id)
      else:
        self.setActiveItem(c.categoryId)
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
  # Update chat items that have that category
  let chatIds = chats.filterIt(it.categoryId == cat.id).mapIt(it.id)
  self.view.chatsModel().updateItemsWithCategoryDetailById(
    chatIds,
    cat.id,
    cat.name,
    cat.position,
  )
  
  if chatIds.len == 0:
    # New category with no chats associated, we created an empty chatItem with the category info
    self.addEmptyChatItemForCategory(cat)
    return

method onCommunityCategoryCreated*(self: Module, cat: Category, chats: seq[ChatDto]) =
  if (self.doesCatOrChatExist(cat.id)):
    return

  if chats.len == 0:
    # New category with no chats associated, we created an empty chatItem with the category info
    self.addEmptyChatItemForCategory(cat)
    return
    
  # Consider the new category as an edit, we just change the chat items with the new cat info
  self.onCommunityCategoryEdited(cat, chats)

method onCommunityCategoryDeleted*(self: Module, cat: Category, chats: seq[ChatDto]) =
  # Update chat positions and remove association with category
  for chat in chats:
    self.view.chatsModel().reorderChatById(
      chat.id,
      chat.position,
      newCategoryId = "",
      newCategoryName = "",
      newCategoryPosition = -1,
    )
  self.view.chatsModel().removeItemById(CATEGORY_ID_PREFIX & cat.id)


method setFirstChannelAsActive*(self: Module) =
  if(self.view.chatsModel().getCount() == 0):
    self.setActiveItem("")
    return
  let chat_item = self.view.chatsModel().getItemAtIndex(0)
  self.setActiveItem(chat_item.id)

method onCommunityCategoryChannelChanged*(self: Module, channelId: string, newCategoryIdForChat: string) =
  if channelId == self.controller.getActiveChatId():
    if newCategoryIdForChat.len > 0:
      self.setActiveItem(channelId)
    else:
      self.setActiveItem(channelId)

method onReorderChat*(self: Module, chatId: string, position: int, newCategoryIdForChat: string, prevCategoryId: string, prevCategoryDeleted: bool) =
  var newCategoryName = ""
  var newCategoryPos = -1
  if newCategoryIdForChat != "":
    let newCategory = self.controller.getCommunityCategoryDetails(self.controller.getMySectionId(), newCategoryIdForChat)
    newCategoryName = newCategory.name
    newCategoryPos = newCategory.position
  self.view.chatsModel().reorderChatById(chatId, position, newCategoryIdForChat, newCategoryName, newCategoryPos)
  if prevCategoryId != "" and not prevCategoryDeleted:
    if not self.view.chatsModel().hasEmptyChatItem(CATEGORY_ID_PREFIX & prevCategoryId):
      let category = self.controller.getCommunityCategoryDetails(self.controller.getMySectionId(), prevCategoryId)
      self.addEmptyChatItemForCategory(category)

method onReorderCategory*(self: Module, catId: string, position: int) =
  self.view.chatsModel().reorderCategoryById(catId, position)

method onCategoryNameChanged*(self: Module, category: Category) =
  self.view.chatsModel().renameCategoryOnItems(category.id, category.name)

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
  if(self.controller.getMySectionId() != singletonInstance.userProfile.getPubKey()):
    return

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

method onMarkAllMessagesRead*(self: Module, chatId: string) =
  self.updateBadgeNotifications(chatId, hasUnreadMessages=false, unviewedMentionsCount=0)
  let chatDetails = self.controller.getChatDetails(chatId)
  if chatDetails.categoryId != "":
    let hasUnreadMessages = self.controller.chatsWithCategoryHaveUnreadMessages(chatDetails.communityId, chatDetails.categoryId)
    self.view.chatsModel().setCategoryHasUnreadMessages(chatDetails.categoryId, hasUnreadMessages)

method markAllMessagesRead*(self: Module, chatId: string) =
  self.controller.markAllMessagesRead(chatId)

method clearChatHistory*(self: Module, chatId: string) =
  self.controller.clearChatHistory(chatId)

method getCurrentFleet*(self: Module): string =
  return self.controller.getCurrentFleet()

method acceptContactRequest*(self: Module, publicKey: string) =
  self.controller.acceptContactRequest(publicKey)

method onContactAdded*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemById(publicKey)

  let contact = self.controller.getContactById(publicKey)
  if (contact.isContact):
    self.switchToOrCreateOneToOneChat(publicKey)

  self.updateParentBadgeNotifications()

method acceptAllContactRequests*(self: Module) =
  let pubKeys = self.view.contactRequestsModel().getItemIds()
  for pk in pubKeys:
    self.acceptContactRequest(pk)

method dismissContactRequest*(self: Module, publicKey: string) =
  self.controller.dismissContactRequest(publicKey)

method onContactRejected*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemById(publicKey)
  self.updateParentBadgeNotifications()

method dismissAllContactRequests*(self: Module) =
  let pubKeys = self.view.contactRequestsModel().getItemIds()
  for pk in pubKeys:
    self.dismissContactRequest(pk)

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method onContactBlocked*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemById(publicKey)
  self.view.chatsModel().changeBlockedOnItemById(publicKey, blocked=true)
  self.updateParentBadgeNotifications()

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
      self.updateParentBadgeNotifications()
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

  # Badge notification
  let showBadge = (not chatDetails.muted and unviewedMessagesCount > 0) or unviewedMentionsCount > 0
  self.updateBadgeNotifications(chatIdMsgBelongsTo, showBadge, unviewedMentionsCount)

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
  let plainText = singletonInstance.utils.plainText(renderedMessageText)
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

method onMeMentionedInEditedMessage*(self: Module, chatId: string, editedMessage : MessageDto) =
  if((editedMessage.communityId.len == 0 and
    self.controller.getMySectionId() != singletonInstance.userProfile.getPubKey()) or
    (editedMessage.communityId.len > 0 and
    self.controller.getMySectionId() != editedMessage.communityId)):
    return
  var (sectionHasUnreadMessages, sectionNotificationCount) = self.view.chatsModel().getAllNotifications()
  self.updateBadgeNotifications(chatId, sectionHasUnreadMessages, sectionNotificationCount + 1)

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
    self.view.editCategoryChannelsModel().appendItem(chatItem)

method reorderCommunityCategories*(self: Module, categoryId: string, position: int) =
  self.controller.reorderCommunityCategories(categoryId, position)

method reorderCommunityChat*(self: Module, categoryId: string, chatId: string, position: int): string =
  self.controller.reorderCommunityChat(categoryId, chatId, position)

method setLoadingHistoryMessagesInProgress*(self: Module, isLoading: bool) =
  self.view.setLoadingHistoryMessagesInProgress(isLoading)

method addChatIfDontExist*(self: Module,
    chat: ChatDto,
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
    setChatAsActive: bool = true) =
  let sectionId = self.controller.getMySectionId()
  if(belongsToCommunity and sectionId != chat.communityId or
    not belongsToCommunity and sectionId != singletonInstance.userProfile.getPubKey()):
    return

  if self.doesCatOrChatExist(chat.id):
    if (chat.chatType == ChatType.PrivateGroupChat):
      self.onGroupChatDetailsUpdated(chat.id, chat.name, chat.color, chat.icon)
    elif (chat.chatType != ChatType.OneToOne):
      self.onChatRenamed(chat.id, chat.name)
    return
  self.addNewChat(chat, belongsToCommunity, events, settingsService, nodeConfigurationService,
    contactService, chatService, communityService, messageService, gifService, mailserversService,
    setChatAsActive)

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
