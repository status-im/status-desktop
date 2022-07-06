import NimQml, Tables, chronicles, json, sequtils, strutils, strformat, sugar

import io_interface
import ../io_interface as delegate_interface
import view, controller, item, sub_item, sub_model, base_item
import model as chats_model
import ../../shared_models/user_item as user_item
import ../../shared_models/user_model as user_model

import chat_content/module as chat_content_module

import ../../../global/app_sections_config as conf
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../core/notifications/details as notification_details
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../app_service/service/gif/service as gif_service
import ../../../../app_service/service/visual_identity/service as visual_identity
import ../../../../app_service/service/contacts/dto/contacts as contacts_dto

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

# Forward declaration
proc buildChatSectionUI(self: Module,
  channelGroup: ChannelGroupDto,
  events: EventEmitter,
  settingsService: settings_service.Service,
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
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service
  ): Module =
  result = Module()
  result.delegate = delegate
  result.controller = controller.newController(result, sectionId, isCommunity, events, settingsService, contactService,
  chatService, communityService, messageService, gifService, mailserversService)
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false

  result.chatContentModules = initOrderedTable[string, chat_content_module.AccessInterface]()

method delete*(self: Module) =
  for cModule in self.chatContentModules.values:
    cModule.delete
  self.chatContentModules.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

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
  contactService: contact_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service) =
  self.chatContentModules[chatId] = chat_content_module.newModule(self, events, self.controller.getMySectionId(), chatId,
    belongToCommunity, isUsersListAvailable, settingsService, contactService, chatService, communityService,
    messageService, gifService, mailserversService)

proc removeSubmodule(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.chatContentModules.del(chatId)

proc buildChatSectionUI(
    self: Module,
    channelGroup: ChannelGroupDto,
    events: EventEmitter,
    settingsService: settings_service.Service,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service) =
  var selectedItemId = ""
  var selectedSubItemId = ""
  
  # handle channels which don't belong to any category
  for chatDto in channelGroup.chats:
    if (chatDto.categoryId != ""):
      continue
    let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
    let notificationsCount = chatDto.unviewedMentionsCount

    var chatName = chatDto.name
    var chatImage = ""
    var colorHash: ColorHashDto = @[]
    var colorId: int = 0
    let isUsersListAvailable = (chatDto.chatType != ChatType.OneToOne and
      chatDto.chatType != ChatType.Public)
    var blocked = false
    let belongToCommunity = chatDto.communityId != ""
    if(chatDto.chatType == ChatType.OneToOne):
      let contactDetails = self.controller.getContactDetails(chatDto.id)
      chatName = contactDetails.displayName
      chatImage = contactDetails.icon
      blocked = contactDetails.details.isBlocked()
      colorHash = self.controller.getColorHash(chatDto.id)
      colorId = self.controller.getColorId(chatDto.id)

    let amIChatAdmin = (self.amIMarkedAsAdminUser(chatDto.members) or channelGroup.admin)
    let channelItem = initItem(chatDto.id, chatName, chatImage, chatDto.color,
      chatDto.emoji, chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification,
      notificationsCount, chatDto.muted, blocked, chatDto.active, chatDto.position,
      chatDto.categoryId, colorId, colorHash)
    self.view.chatsModel().appendItem(channelItem)
    self.addSubmodule(chatDto.id, belongToCommunity, isUsersListAvailable, events, settingsService,
      contactService, chatService, communityService, messageService, gifService, mailserversService)

    # make the first channel which doesn't belong to any category active when load the app
    if(selectedItemId.len == 0):
      selectedItemId = channelItem.id

  # handle categories and channels for each category
  for cat in channelGroup.categories:
    var hasNotificationPerCategory = false
    var notificationsCountPerCategory = 0
    var categoryChannels: seq[SubItem]

    let categoryChats = channelGroup.chats.filter(c => c.categoryId == cat.id)
    for chatDto in categoryChats:

      let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
      let notificationsCount = chatDto.unviewedMentionsCount

      hasNotificationPerCategory = hasNotificationPerCategory or hasNotification
      notificationsCountPerCategory += notificationsCount

      let amIChatAdmin = channelGroup.admin

      let channelItem = initSubItem(chatDto.id, cat.id, chatDto.name, chatDto.icon,
        chatDto.color, chatDto.emoji, chatDto.description, chatDto.chatType.int,
        amIChatAdmin, hasNotification, notificationsCount, chatDto.muted, blocked=false,
        active=false, chatDto.position)
      categoryChannels.add(channelItem)
      self.addSubmodule(chatDto.id, belongToCommunity=true, isUsersListAvailable=true, events,
        settingsService, contactService, chatService, communityService, messageService, gifService,
        mailserversService)

      # in case there is no channels beyond categories,
      # make the first channel of the first category active when load the app
      if(selectedItemId.len == 0):
        selectedItemId = cat.id
        selectedSubItemId = channelItem.id

    var categoryItem = initItem(cat.id, cat.name, icon="", color="", emoji="",
      description="", ChatType.Unknown.int, amIChatAdmin=false, hasNotificationPerCategory,
      notificationsCountPerCategory, muted=false, blocked=false, active=false,
      cat.position, cat.id)
    categoryItem.prependSubItems(categoryChannels)
    self.view.chatsModel().appendItem(categoryItem)

  self.setActiveItemSubItem(selectedItemId, selectedSubItemId)

proc createItemFromPublicKey(self: Module, publicKey: string): UserItem =
  let contactDetails = self.controller.getContactDetails(publicKey)

  return initUserItem(
    pubKey = contactDetails.details.id,
    displayName = contactDetails.displayName,
    icon = contactDetails.icon,
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
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service) =
  self.controller.init()
  self.view.load()

  self.buildChatSectionUI(channelGroup, events, settingsService, contactService, chatService,
    communityService, messageService, gifService, mailserversService)

  if(not self.controller.isCommunity()):
    # we do this only in case of chat section (not in case of communities)
    self.initContactRequestsModel()

  for cModule in self.chatContentModules.values:
    cModule.load()

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

method setActiveItemSubItem*(self: Module, itemId: string, subItemId: string) =
  self.controller.setActiveItemSubItem(itemId, subItemId)

method makeChatWithIdActive*(self: Module, chatId: string) =
  var item = self.view.chatsModel().getItemById(chatId)
  var subItemId: string
  if(item.isNil):
    let subItem = self.view.chatsModel().getSubItemById(chatId)
    if(subItem.isNil):
      # Should never be here
      error "trying to make chat/channel active for an unexisting id ", chatId, methodName="makeChatWithIdActive"
      return

    subItemId = subItem.BaseItem.id
    item = self.view.chatsModel().getItemById(subItem.parentId())
    if(item.isNil):
      # Should never be here
      error "unexisting parent item with id ", subItemId, methodName="makeChatWithIdActive"
      return

  # here, in this step we have appropriate item and subitem assigned
  self.setActiveItemSubItem(item.BaseItem.id, subItemId)

method activeItemSubItemSet*(self: Module, itemId: string, subItemId: string) =
  let item = self.view.chatsModel().getItemById(itemId)
  if(item.isNil):
    # Should never be here
    error "chat-view unexisting item id: ", itemId, methodName="activeItemSubItemSet"
    return

  # Chats from Chat section and chats from Community section which don't belong
  # to any category have empty `subItemId`
  let subItem = item.subItems.getItemById(subItemId)

  # update view maintained by this module
  self.view.chatsModel().setActiveItemSubItem(itemId, subItemId)
  self.view.activeItemSubItemSet(item, subItem)
  # notify parent module about active chat/channel
  self.delegate.onActiveChatChange(self.controller.getMySectionId(), self.controller.getActiveChatId())
  # update notifications caused by setting active chat/channel
  self.controller.markAllMessagesRead(self.controller.getActiveChatId())

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
    sectionNotificationCount += self.view.contactRequestsModel().getCount()
    sectionHasUnreadMessages = sectionHasUnreadMessages or sectionNotificationCount > 0
  self.delegate.onNotificationsUpdated(self.controller.getMySectionId(), sectionHasUnreadMessages, sectionNotificationCount)

proc updateBadgeNotifications(self: Module, chatId: string, hasUnreadMessages: bool, unviewedMentionsCount: int) =
  # update model of this module (appropriate chat from the chats list (chats model))
  self.view.chatsModel().updateNotificationsForItemOrSubItemById(chatId, hasUnreadMessages, unviewedMentionsCount)
  # update child module
  if (self.chatContentModules.contains(chatId)):
    self.chatContentModules[chatId].onNotificationsUpdated(hasUnreadMessages, unviewedMentionsCount)
  # update parent module
  self.updateParentBadgeNotifications()

method onActiveSectionChange*(self: Module, sectionId: string) =
  if(sectionId != self.controller.getMySectionId()):
    return

  self.updateBadgeNotifications(self.controller.getActiveChatId(), hasUnreadMessages=false, unviewedMentionsCount=0)
  self.delegate.onActiveChatChange(self.controller.getMySectionId(), self.controller.getActiveChatId())

method chatsModel*(self: Module): chats_model.Model =
  return self.view.chatsModel()

method createPublicChat*(self: Module, chatId: string) =
  if(self.controller.isCommunity()):
    debug "creating public chat is not allowed for community, most likely it's an error in qml", methodName="createPublicChat"
    return

  if(self.chatContentModules.hasKey(chatId)):
    self.setActiveItemSubItem(chatId, "")
    return

  self.controller.createPublicChat(chatId)

method addNewChat*(
    self: Module,
    chatDto: ChatDto,
    belongsToCommunity: bool,
    events: EventEmitter,
    settingsService: settings_service.Service,
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
  var isUsersListAvailable = true
  if(chatDto.chatType == ChatType.OneToOne):
    isUsersListAvailable = false
    (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(chatDto.id)
    colorHash = self.controller.getColorHash(chatDto.id)
    colorId = self.controller.getColorId(chatDto.id)

  var amIChatAdmin = false
  if(belongsToCommunity):
    amIChatAdmin = self.controller.getMyCommunity().admin
  else:
    amIChatAdmin = self.amIMarkedAsAdminUser(chatDto.members)

  if chatDto.categoryId.len == 0:
    let item = initItem(chatDto.id, chatName, chatImage, chatDto.color, chatDto.emoji,
      chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount,
      chatDto.muted, blocked=false, active=false, position = 0, chatDto.categoryId, colorId, colorHash, chatDto.highlight)
    self.addSubmodule(chatDto.id, belongsToCommunity, isUsersListAvailable, events, settingsService, contactService, chatService,
                      communityService, messageService, gifService, mailserversService)
    self.chatContentModules[chatDto.id].load()
    self.view.chatsModel().appendItem(item)
    if setChatAsActive:
      self.setActiveItemSubItem(item.id, "")
  else:
    let categoryItem = self.view.chatsModel().getItemById(chatDto.categoryId)
    if(categoryItem.isNil):
      error "A category you're trying to add channel to doesn't exist", categoryId=chatDto.categoryId
      return

    let channelItem = initSubItem(chatDto.id, chatDto.categoryId, chatDto.name, chatDto.icon,
      chatDto.color, chatDto.emoji, chatDto.description, chatDto.chatType.int,
      amIChatAdmin, hasNotification, notificationsCount, chatDto.muted, blocked=false, active=false,
      chatDto.position)
    self.addSubmodule(chatDto.id, belongsToCommunity, isUsersListAvailable, events, settingsService, contactService, chatService,
                      communityService, messageService, gifService, mailserversService)
    self.chatContentModules[chatDto.id].load()
    categoryItem.appendSubItem(channelItem)
    if setChatAsActive:
      self.setActiveItemSubItem(categoryItem.id, channelItem.id)

method doesCatOrChatExist*(self: Module, id: string): bool =
  return self.view.chatsModel().isItemWithIdAdded(id) or
    not self.view.chatsModel().getSubItemById(id).isNil

method doesTopLevelChatExist*(self: Module, chatId: string): bool =
  return self.view.chatsModel().isItemWithIdAdded(chatId)

method removeCommunityChat*(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return

  self.controller.removeCommunityChat(chatId)

method onCommunityCategoryCreated*(self: Module, cat: Category, chats: seq[ChatDto]) =
  if (self.doesCatOrChatExist(cat.id)):
    return
  var categoryItem = initItem(cat.id, cat.name, icon="", color="", emoji="",
    description="", ChatType.Unknown.int, amIChatAdmin=false, hasUnreadMessages=false,
    notificationsCount=0, muted=false, blocked=false, active=false, cat.position, cat.id)
  var categoryChannels: seq[SubItem]
  for chatDto in chats:
    let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
    let notificationsCount = chatDto.unviewedMentionsCount
    let channelItem = initSubItem(chatDto.id, cat.id, chatDto.name, chatDto.icon,
      chatDto.color, chatDto.emoji, chatDto.description, chatDto.chatType.int,
      amIChatAdmin=true, hasNotification, notificationsCount, chatDto.muted, blocked=false,
      active=false, chatDto.position)

    # Important:
    # Since we're just adding an already added community channel to a certain community, there is no need to call
    # `self.addSubmodule` here, since submodule (chat content module and modules beneath) were already added, so we're
    # just updating the view from here, via model.
    self.view.chatsModel().removeItemById(chatDto.id)
    categoryChannels.add(channelItem)

  categoryItem.prependSubItems(categoryChannels)
  self.view.chatsModel().appendItem(categoryItem)

method onCommunityCategoryDeleted*(self: Module, cat: Category) =
  let chats = self.controller.getChats(self.controller.getMySectionId(), cat.id)
  for c in chats:
    if (c.categoryId != cat.id or self.doesTopLevelChatExist(self.controller.getMySectionId() & c.id)):
      continue
    let chatDto = self.controller.getChatDetails(c.id)
    let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
    let notificationsCount = chatDto.unviewedMentionsCount
    let amIChatAdmin = self.controller.getMyCommunity().admin
    let channelItem = initItem(chatDto.id, chatDto.name, chatDto.icon,
      chatDto.color, chatDto.emoji, chatDto.description, chatDto.chatType.int, amIChatAdmin,
      hasNotification, notificationsCount, chatDto.muted, false, active = false,
      chatDto.position, categoryId="")
    self.view.chatsModel().removeItemById(c.id)
    self.view.chatsModel().appendItem(channelItem)

  self.view.chatsModel().removeItemById(cat.id)

method setFirstChannelAsActive*(self: Module) =
  if(self.view.chatsModel().getCount() == 0):
    return
  let item = self.view.chatsModel().getItemAtIndex(0)
  if(item.subItems.getCount() == 0):
    self.setActiveItemSubItem(item.id, "")
  else:
    let subItem = item.subItems.getItemAtIndex(0)
    self.setActiveItemSubItem(item.id, subItem.id)

method onReorderChatOrCategory*(self: Module, chatOrCatId: string, position: int) =
  self.view.chatsModel().reorder(chatOrCatId, position)
  self.setFirstChannelAsActive()

method onCategoryNameChanged*(self: Module, category: Category) =
  self.view.chatsModel().renameItem(category.id, category.name)

method onCommunityCategoryEdited*(self: Module, cat: Category, chats: seq[ChatDto]) =
  var categoryItem = self.view.chatsModel().getItemById(cat.id)
  let amIChatAdmin = self.controller.getMyCommunity().admin

  self.view.chatsModel.renameItem(cat.id, cat.name)

  for chatDto in chats:
    let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
    let notificationsCount = chatDto.unviewedMentionsCount

    self.view.chatsModel().removeItemById(chatDto.id)
    categoryItem.subItems().removeItemById(chatDto.id)

    if chatDto.categoryId == cat.id:
      let channelItem = initSubItem(chatDto.id, cat.id, chatDto.name, chatDto.icon,
        chatDto.color, chatDto.emoji, chatDto.description, chatDto.chatType.int,
        amIChatAdmin=true, hasNotification, notificationsCount, chatDto.muted, blocked=false,
        active=false, chatDto.position)
      categoryItem.prependSubItem(channelItem)
    else:
      let channelItem = initItem(chatDto.id, chatDto.name, chatDto.icon,
        chatDto.color, chatDto.emoji, chatDto.description, chatDto.chatType.int, amIChatAdmin,
        hasNotification, notificationsCount, chatDto.muted, blocked=false, active = false,
        chatDto.position, categoryId="")
      self.view.chatsModel().appendItem(channelItem)

method onCommunityChannelDeletedOrChatLeft*(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.view.chatsModel().removeItemById(chatId)
  self.removeSubmodule(chatId)

  self.setFirstChannelAsActive()

method onCommunityChannelEdited*(self: Module, chat: ChatDto) =
  if(not self.chatContentModules.contains(chat.id)):
    return
  self.view.chatsModel().updateItemDetails(chat.id, chat.name, chat.description, chat.emoji,
    chat.color)

method switchToOrCreateOneToOneChat*(self: Module, chatId: string) =
  # One To One chat is available only in the `Chat` section
  if(self.controller.getMySectionId() != singletonInstance.userProfile.getPubKey()):
    return

  if(self.chatContentModules.hasKey(chatId)):
    self.setActiveItemSubItem(chatId, "")
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
  self.view.chatsModel().muteUnmuteItemsOrSubItemsByCategoryId(categoryId, true)

method onCategoryUnmuted*(self: Module, categoryId: string) =
  self.view.chatsModel().muteUnmuteItemsOrSubItemsByCategoryId(categoryId, false)

method onChatMuted*(self: Module, chatId: string) =
  self.view.chatsModel().muteUnmuteItemOrSubItemById(chatId, mute=true)

method onChatUnmuted*(self: Module, chatId: string) =
  self.view.chatsModel().muteUnmuteItemOrSubItemById(chatId, false)

method onMarkAllMessagesRead*(self: Module, chatId: string) =
  self.updateBadgeNotifications(chatId, hasUnreadMessages=false, unviewedMentionsCount=0)

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
  self.view.chatsModel().blockUnblockItemOrSubItemById(publicKey, blocked=true)

method onContactUnblocked*(self: Module, publicKey: string) =
  self.view.chatsModel().blockUnblockItemOrSubItemById(publicKey, blocked=false)

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
      fmt "{contactDetails.displayName} added you as contact",
        singletonInstance.userProfile.getPubKey())

  let chatName = contactDetails.displayName
  let chatImage = contactDetails.icon
  let trustStatus = contactDetails.details.trustStatus
  self.view.chatsModel().updateItemDetails(publicKey, chatName, chatImage, trustStatus)

method onNewMessagesReceived*(self: Module, sectionIdMsgBelongsTo: string, chatIdMsgBelongsTo: string, 
  chatTypeMsgBelongsTo: ChatType, unviewedMessagesCount: int, unviewedMentionsCount: int, message: MessageDto) =
  let messageBelongsToActiveSection = sectionIdMsgBelongsTo == self.controller.getMySectionId() and 
    self.controller.getMySectionId() == self.delegate.getActiveSectionId()
  let messageBelongsToActiveChat = self.controller.getActiveChatId() == chatIdMsgBelongsTo
  if(not messageBelongsToActiveSection or not messageBelongsToActiveChat):
    let hasUnreadMessages = unviewedMessagesCount > 0
    self.updateBadgeNotifications(chatIdMsgBelongsTo, hasUnreadMessages, unviewedMentionsCount)

  # Prepare notification
  let myPK = singletonInstance.userProfile.getPubKey()
  var notificationType = notification_details.NotificationType.NewMessage
  if(message.isPersonalMention(myPK)):
    notificationType = notification_details.NotificationType.NewMessageWithPersonalMention
  elif(message.isGlobalMention()):
    notificationType = notification_details.NotificationType.NewMessageWithGlobalMention
  let contactDetails = self.controller.getContactDetails(message.`from`)
  let renderedMessageText = self.controller.getRenderedText(message.parsedText)
  let plainText = singletonInstance.utils.plainText(renderedMessageText)
  singletonInstance.globalEvents.showMessageNotification(contactDetails.displayName, plainText, sectionIdMsgBelongsTo, 
    self.controller.isCommunity(), messageBelongsToActiveSection, chatIdMsgBelongsTo, messageBelongsToActiveChat, 
    message.id, notificationType.int, 
    chatTypeMsgBelongsTo == ChatType.OneToOne, chatTypeMsgBelongsTo == ChatType.PrivateGroupChat)

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

method makeAdmin*(self: Module, communityID: string, chatId: string, pubKey: string) =
  self.controller.makeAdmin(communityID, chatId, pubKey)

method createGroupChat*(self: Module, communityID: string, groupName: string, pubKeys: string) =
  self.controller.createGroupChat(communityID, groupName, self.convertPubKeysToJson(pubKeys))

method createGroupChat*(self: Module, groupName: string, pubKeys: seq[string]) =
  self.controller.createGroupChat("", groupName, pubKeys)

method joinGroupChatFromInvitation*(self: Module, groupName: string, chatId: string, adminPK: string) =
  self.controller.joinGroupChatFromInvitation(groupName, chatId, adminPK)

method onChatRenamed*(self: Module, chatId: string, newName: string) =
  self.view.chatsModel().renameItem(chatId, newName)

method acceptRequestToJoinCommunity*(self: Module, requestId: string) =
  self.controller.acceptRequestToJoinCommunity(requestId)

method declineRequestToJoinCommunity*(self: Module, requestId: string) =
  self.controller.declineRequestToJoinCommunity(requestId)

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

method inviteUsersToCommunity*(self: Module, pubKeysJSON: string): string =
  result = self.controller.inviteUsersToCommunity(pubKeysJSON)

method prepareEditCategoryModel*(self: Module, categoryId: string) =
  self.view.editCategoryChannelsModel().clearItems()
  let communityId = self.controller.getMySectionId()
  let chats = self.controller.getChats(communityId, "")
  for chat in chats:
    let c = self.controller.getChatDetails(chat.id)
    let item = initItem(c.id, c.name, icon="", c.color, c.emoji, c.description,
      c.chatType.int, amIChatAdmin=false, hasUnreadMessages=false, notificationsCount=0, c.muted,
      blocked=false, active=false, c.position, categoryId="")
    self.view.editCategoryChannelsModel().appendItem(item)
  let catChats = self.controller.getChats(communityId, categoryId)
  for chat in catChats:
    let c = self.controller.getChatDetails(chat.id)
    let item = initItem(c.id, c.name, icon="", c.color, c.emoji, c.description,
      c.chatType.int, amIChatAdmin=false, hasUnreadMessages=false, notificationsCount=0, c.muted,
      blocked=false, active=false, c.position, categoryId)
    self.view.editCategoryChannelsModel().appendItem(item)

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
    if(chat.chatType != ChatType.OneToOne):
      self.onChatRenamed(chat.id, chat.name)
    return
  self.addNewChat(chat, belongsToCommunity, events, settingsService, contactService, chatService,
    communityService, messageService, gifService, mailserversService, setChatAsActive)

method downloadMessages*(self: Module, chatId: string, filePath: string) =
  if(not self.chatContentModules.contains(chatId)):
    error "unexisting chat key: ", chatId, methodName="downloadMessages"
    return

  self.chatContentModules[chatId].downloadMessages(filePath)
