import NimQml, Tables, chronicles, json, sequtils
import io_interface
import ../io_interface as delegate_interface
import view, controller, item, sub_item, model, sub_model, base_item
import ../../shared_models/contacts_item as contacts_item
import ../../shared_models/contacts_model as contacts_model

import chat_content/module as chat_content_module

import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/gif/service as gif_service

export io_interface

logScope:
  topics = "chat-section-module"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatContentModules: OrderedTable[string, chat_content_module.AccessInterface]
    moduleLoaded: bool


proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    sectionId: string,
    isCommunity: bool, 
    settingsService: settings_service.ServiceInterface,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service, 
    messageService: message_service.Service,
    gifService: gif_service.Service,
  ): Module =
  result = Module()
  result.delegate = delegate
  result.controller = controller.newController(result, sectionId, isCommunity, events, settingsService, contactService, 
  chatService, communityService, messageService, gifService)
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

proc amIMarkedAsAdminUser(self: Module, members: seq[ChatMember]): bool = 
  for m in members:
    if (m.id == singletonInstance.userProfile.getPubKey() and m.admin):
      return true
  return false

proc addSubmodule(self: Module, chatId: string, belongToCommunity: bool, isUsersListAvailable: bool, events: EventEmitter, 
  settingsService: settings_service.ServiceInterface, 
  contactService: contact_service.Service, 
  chatService: chat_service.Service, 
  communityService: community_service.Service, 
  messageService: message_service.Service,
  gifService: gif_service.Service) =
  self.chatContentModules[chatId] = chat_content_module.newModule(self, events, self.controller.getMySectionId(), chatId,
    belongToCommunity, isUsersListAvailable, settingsService, contactService, chatService, communityService, 
    messageService, gifService)

proc removeSubmodule(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.chatContentModules.del(chatId)

proc buildChatUI(self: Module, events: EventEmitter, 
  settingsService: settings_service.ServiceInterface, 
  contactService: contact_service.Service, 
  chatService: chat_service.Service, 
  communityService: community_service.Service, 
  messageService: message_service.Service,
  gifService: gif_service.Service) =
  let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
  let chats = self.controller.getChatDetailsForChatTypes(types)

  var selectedItemId = ""
  for c in chats:
    let hasNotification = c.unviewedMessagesCount > 0 or c.unviewedMentionsCount > 0
    let notificationsCount = c.unviewedMentionsCount
    var chatName = c.name
    var chatImage = c.identicon
    var isIdenticon = false
    var isUsersListAvailable = true
    if(c.chatType == ChatType.OneToOne):
      isUsersListAvailable = false
      (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(c.id)

    let amIChatAdmin = self.amIMarkedAsAdminUser(c.members)

    let item = initItem(c.id, chatName, chatImage, isIdenticon, c.color, c.description, c.chatType.int, amIChatAdmin, 
    hasNotification, notificationsCount, c.muted, active = false, c.position, c.categoryId)
    self.view.chatsModel().appendItem(item)
    self.addSubmodule(c.id, false, isUsersListAvailable, events, settingsService, contactService, chatService, 
    communityService, messageService, gifService)
    
    # make the first Public chat active when load the app
    if(selectedItemId.len == 0 and c.chatType == ChatType.Public):
      selectedItemId = item.id

  self.setActiveItemSubItem(selectedItemId, "")

proc buildCommunityUI(self: Module, events: EventEmitter, 
  settingsService: settings_service.ServiceInterface,
  contactService: contact_service.Service, 
  chatService: chat_service.Service, 
  communityService: community_service.Service, 
  messageService: message_service.Service,
  gifService: gif_service.Service) =
  var selectedItemId = ""
  var selectedSubItemId = ""
  let communities = self.controller.getJoinedCommunities()
  for comm in communities:
    if(self.controller.getMySectionId() != comm.id):
      continue
    
    # handle channels which don't belong to any category
    let chats = self.controller.getChats(comm.id, "")
    for c in chats:
      let chatDto = self.controller.getChatDetails(comm.id, c.id)

      let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
      let notificationsCount = chatDto.unviewedMentionsCount
      let amIChatAdmin = comm.admin
      let channelItem = initItem(chatDto.id, chatDto.name, chatDto.identicon, false, chatDto.color,
        chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount,
        chatDto.muted, active = false, c.position, c.categoryId)
      self.view.chatsModel().appendItem(channelItem)
      self.addSubmodule(chatDto.id, true, true, events, settingsService, contactService, chatService, communityService, 
      messageService, gifService)

      # make the first channel which doesn't belong to any category active when load the app
      if(selectedItemId.len == 0):
        selectedItemId = channelItem.id

    # handle categories and channels for each category
    let categories = self.controller.getCategories(comm.id)
    for cat in categories:
      var hasNotificationPerCategory = false
      var notificationsCountPerCategory = 0
      var categoryChannels: seq[SubItem]

      let categoryChats = self.controller.getChats(comm.id, cat.id)
      for c in categoryChats:
        let chatDto = self.controller.getChatDetails(comm.id, c.id)
        
        let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
        let notificationsCount = chatDto.unviewedMentionsCount

        hasNotificationPerCategory = hasNotificationPerCategory or hasNotification
        notificationsCountPerCategory += notificationsCount

        let amIChatAdmin = comm.admin

        let channelItem = initSubItem(chatDto.id, cat.id, chatDto.name, chatDto.identicon, false, chatDto.color, 
        chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount, chatDto.muted, 
        false, c.position)
        categoryChannels.add(channelItem)
        self.addSubmodule(chatDto.id, true, true, events, settingsService, contactService, chatService, communityService, 
        messageService, gifService)

        # in case there is no channels beyond categories, 
        # make the first channel of the first category active when load the app
        if(selectedItemId.len == 0):
          selectedItemId = cat.id
          selectedSubItemId = channelItem.id

      var categoryItem = initItem(cat.id, cat.name, "", false, "", "", ChatType.Unknown.int, false, 
        hasNotificationPerCategory, notificationsCountPerCategory, false, false, cat.position, cat.id)
      categoryItem.prependSubItems(categoryChannels)
      self.view.chatsModel().appendItem(categoryItem)

  self.setActiveItemSubItem(selectedItemId, selectedSubItemId)

proc createItemFromPublicKey(self: Module, publicKey: string): contacts_item.Item =
  let contactDetails = self.controller.getContactDetails(publicKey)
  
  return contacts_item.initItem(
    contactDetails.details.id,
    contactDetails.displayName,
    contactDetails.icon,
    contactDetails.isIdenticon,
    contactDetails.details.isContact(),
    contactDetails.details.isBlocked(), 
    contactDetails.details.requestReceived()
  )

proc initContactRequestsModel(self: Module) =
  var contactsWhoAddedMe: seq[contacts_item.Item]
  let contacts =  self.controller.getContacts()
  for c in contacts:
    if(c.requestReceived() and not c.isContact() and not c.isBlocked()):
      let item = self.createItemFromPublicKey(c.id)
      contactsWhoAddedMe.add(item)

  self.view.contactRequestsModel().addItems(contactsWhoAddedMe)

method initListOfMyContacts*(self: Module) =
  var myContacts: seq[contacts_item.Item]
  let contacts =  self.controller.getContacts()
  for c in contacts:
    if(c.isContact() and not c.isBlocked()):
      let item = self.createItemFromPublicKey(c.id)
      myContacts.add(item)
  
  self.view.listOfMyContacts().addItems(myContacts)

method clearListOfMyContacts*(self: Module) =
  self.view.listOfMyContacts().clear()
    

method load*(self: Module, events: EventEmitter, 
  settingsService: settings_service.ServiceInterface,
  contactService: contact_service.Service, 
  chatService: chat_service.Service, 
  communityService: community_service.Service, 
  messageService: message_service.Service,
  gifService: gif_service.Service) =
  self.controller.init()
  self.view.load()
  
  if(self.controller.isCommunity()):
    self.buildCommunityUI(events, settingsService, contactService, chatService, communityService, messageService, gifService)
  else:
    self.buildChatUI(events, settingsService, contactService, chatService, communityService, messageService, gifService)
    self.initContactRequestsModel() # we do this only in case of chat section (not in case of communities)

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

method onActiveSectionChange*(self: Module, sectionId: string) =
  if(sectionId != self.controller.getMySectionId()):
    return
  
  self.delegate.onActiveChatChange(self.controller.getMySectionId(), self.controller.getActiveChatId())

method createPublicChat*(self: Module, chatId: string) =
  if(self.controller.isCommunity()):
    debug "creating public chat is not allowed for community, most likely it's an error in qml", methodName="createPublicChat"
    return

  if(self.chatContentModules.hasKey(chatId)):
    error "error: public chat is already added", chatId, methodName="createPublicChat"
    return

  self.controller.createPublicChat(chatId)

method addNewChat*(
    self: Module,
    chatDto: ChatDto,
    belongsToCommunity: bool,
    events: EventEmitter, 
    settingsService: settings_service.ServiceInterface,
    contactService: contact_service.Service,
    chatService: chat_service.Service, 
    communityService: community_service.Service, 
    messageService: message_service.Service,
    gifService: gif_service.Service) =
  let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
  let notificationsCount = chatDto.unviewedMentionsCount
  var chatName = chatDto.name
  var chatImage = chatDto.identicon
  var isIdenticon = false
  var isUsersListAvailable = true
  if(chatDto.chatType == ChatType.OneToOne):
    isUsersListAvailable = false
    (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(chatDto.id)
  var amIChatAdmin = false
  if(belongsToCommunity):
    amIChatAdmin = self.controller.getMyCommunity().admin
  else:
    amIChatAdmin = self.amIMarkedAsAdminUser(chatDto.members)

  if chatDto.categoryId == "":  
    let item = initItem(chatDto.id, chatName, chatImage, isIdenticon, chatDto.color, chatDto.description, 
                        chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount, chatDto.muted,
                        active = false, position = 0, chatDto.categoryId)
    self.addSubmodule(chatDto.id, belongsToCommunity, isUsersListAvailable, events, settingsService, contactService, chatService,
                      communityService, messageService, gifService)
    self.chatContentModules[chatDto.id].load()
    self.view.chatsModel().appendItem(item)
    # make new added chat active one
    self.setActiveItemSubItem(item.id, "")
  else:
    let categoryItem = self.view.chatsModel().getItemById(chatDto.categoryId)
    let channelItem = initSubItem(chatDto.id, chatDto.categoryId, chatDto.name, chatDto.identicon, false, chatDto.color, 
        chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount, chatDto.muted, 
        false, chatDto.position)
    self.addSubmodule(chatDto.id, belongsToCommunity, isUsersListAvailable, events, settingsService, contactService, chatService,
                      communityService, messageService, gifService)
    self.chatContentModules[chatDto.id].load()
    categoryItem.appendSubItem(channelItem)
    self.setActiveItemSubItem(categoryItem.id, channelItem.id)

method removeCommunityChat*(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return

  self.controller.removeCommunityChat(chatId)

method onCommunityCategoryCreated*(self: Module, cat: Category, chats: seq[ChatDto]) =
  var categoryItem = initItem(cat.id, cat.name, "", false, "", "", ChatType.Unknown.int, false, 
      false, 0, false, false, cat.position, cat.id)
  var categoryChannels: seq[SubItem]
  for chatDto in chats:
    let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
    let notificationsCount = chatDto.unviewedMentionsCount
    let channelItem = initSubItem(chatDto.id, cat.id, chatDto.name, chatDto.identicon, false, chatDto.color, 
        chatDto.description, chatDto.chatType.int, true, hasNotification, notificationsCount, chatDto.muted, 
        false, chatDto.position)

    # Important:
    # Since we're just adding an already added community channel to a certain commuinity, there is no need to call
    # `self.addSubmodule` here, since submodule (chat content module and modules beneath) were already added, so we're
    # just updating the view from here, via model.    
    self.view.chatsModel().removeItemById(chatDto.id)
    categoryChannels.add(channelItem)

  categoryItem.prependSubItems(categoryChannels)
  self.view.chatsModel().appendItem(categoryItem)

method onCommunityCategoryDeleted*(self: Module, cat: Category) =
  let chats = self.controller.getChats(self.controller.getMySectionId(), cat.id)
  for c in chats:
    let chatDto = self.controller.getChatDetails(self.controller.getMySectionId(), c.id)
    let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
    let notificationsCount = chatDto.unviewedMentionsCount
    let amIChatAdmin = self.controller.getMyCommunity().admin
    let channelItem = initItem(chatDto.id, chatDto.name, chatDto.identicon, false, chatDto.color,
        chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount,
        chatDto.muted, active = false, chatDto.position, "")
    self.view.chatsModel().appendItem(channelItem)

  self.view.chatsModel().removeItemById(cat.id)
  
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
      let channelItem = initSubItem(chatDto.id, cat.id, chatDto.name, chatDto.identicon, false, chatDto.color, 
          chatDto.description, chatDto.chatType.int, true, hasNotification, notificationsCount, chatDto.muted, 
          false, chatDto.position)
      categoryItem.prependSubItem(channelItem)
    else:
      let channelItem = initItem(chatDto.id, chatDto.name, chatDto.identicon, false, chatDto.color,
        chatDto.description, chatDto.chatType.int, amIChatAdmin, hasNotification, notificationsCount,
        chatDto.muted, active = false, chatDto.position, "")
      self.view.chatsModel().appendItem(channelItem)

method onCommunityChannelDeletedOrChatLeft*(self: Module, chatId: string) =
  if(not self.chatContentModules.contains(chatId)):
    return
  self.view.chatsModel().removeItemById(chatId)
  self.removeSubmodule(chatId)

  if(self.view.chatsModel().getCount() == 0):
    return

  # set first channel as the active one in model
  let item = self.view.chatsModel().getItemAtIndex(0)
  if(item.subItems.getCount() == 0):
    self.setActiveItemSubItem(item.id, "")
  else:
    let subItem = item.subItems.getItemAtIndex(0)
    self.setActiveItemSubItem(item.id, subItem.id)

method onCommunityChannelEdited*(self: Module, chat: ChatDto) =
  if(not self.chatContentModules.contains(chat.id)):
    return
  self.view.chatsModel().updateItemDetails(chat.id, chat.name, chat.description)

method createOneToOneChat*(self: Module, chatId: string, ensName: string) =
  if(self.controller.isCommunity()):
    debug "creating an one to one chat is not allowed for community, most likely it's an error in qml", methodName="createOneToOneChat"
    return

  if(self.chatContentModules.hasKey(chatId)):
    self.setActiveItemSubItem(chatId, "")
    return

  self.controller.createOneToOneChat(chatId, ensName)

proc updateNotifications(self: Module, chatId: string, unviewedMessagesCount: int, unviewedMentionsCount: int) =
  let hasUnreadMessages = unviewedMessagesCount > 0
  # update model of this module (appropriate chat from the chats list (chats model))
  self.view.chatsModel().updateNotificationsForItemOrSubItemById(chatId, hasUnreadMessages, unviewedMentionsCount)
  # update child module
  if (self.chatContentModules.contains(chatId)):
    self.chatContentModules[chatId].onNotificationsUpdated(hasUnreadMessages, unviewedMentionsCount)
  # update parent module
  let (sectionHasUnreadMessages, sectionNotificationCount) = self.view.chatsModel().getAllNotifications()
  self.delegate.onNotificationsUpdated(self.controller.getMySectionId(), sectionHasUnreadMessages, sectionNotificationCount)

method leaveChat*(self: Module, chatId: string) =
  self.controller.leaveChat(chatId)

method muteChat*(self: Module, chatId: string) =
  self.controller.muteChat(chatId)

method unmuteChat*(self: Module, chatId: string) =
  self.controller.unmuteChat(chatId)

method onChatMuted*(self: Module, chatId: string) =
  self.view.chatsModel().muteUnmuteItemOrSubItemById(chatId, mute=true)

method onChatUnmuted*(self: Module, chatId: string) =
  self.view.chatsModel().muteUnmuteItemOrSubItemById(chatId, false)

method onMarkAllMessagesRead*(self: Module, chatId: string) =
  self.updateNotifications(chatId, unviewedMessagesCount=0, unviewedMentionsCount=0)

method markAllMessagesRead*(self: Module, chatId: string) =
  self.controller.markAllMessagesRead(chatId)

method clearChatHistory*(self: Module, chatId: string) =
  self.controller.clearChatHistory(chatId)

method getCurrentFleet*(self: Module): string =
  return self.controller.getCurrentFleet()

method acceptContactRequest*(self: Module, publicKey: string) =
  self.controller.addContact(publicKey)
  self.createOneToOneChat(publicKey, ensName = "")

method onContactAccepted*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemWithPubKey(publicKey)

method acceptAllContactRequests*(self: Module) =
  let pubKeys = self.view.contactRequestsModel().getPublicKeys()
  for pk in pubKeys:
    self.acceptContactRequest(pk)

method rejectContactRequest*(self: Module, publicKey: string) =
  self.controller.rejectContactRequest(publicKey)

method onContactRejected*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemWithPubKey(publicKey)

method rejectAllContactRequests*(self: Module) =
  let pubKeys = self.view.contactRequestsModel().getPublicKeys()
  for pk in pubKeys:
    self.rejectContactRequest(pk)

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method onContactBlocked*(self: Module, publicKey: string) =
  self.view.contactRequestsModel().removeItemWithPubKey(publicKey)

method onContactDetailsUpdated*(self: Module, publicKey: string) =
  let contact = self.controller.getContact(publicKey)
  if (contact.requestReceived() and
    not contact.isContact()and
    not contact.isBlocked() and
    not self.view.contactRequestsModel().containsItemWithPubKey(publicKey)):
      let item = self.createItemFromPublicKey(publicKey)
      self.view.contactRequestsModel().addItem(item)

  let (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(publicKey)
  self.view.chatsModel().updateItemDetails(publicKey, chatName, chatImage, isIdenticon)

method onNewMessagesReceived*(self: Module, chatId: string, unviewedMessagesCount: int, unviewedMentionsCount: int, 
  messages: seq[MessageDto]) =
  let activeChatId = self.controller.getActiveChatId()
  if(activeChatId == chatId):
    self.controller.markAllMessagesRead(chatId)
  else:
    self.updateNotifications(chatId, unviewedMessagesCount, unviewedMentionsCount)

proc convertPubKeysToJson(self: Module, pubKeys: string): seq[string] =
  return map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)

method addGroupMembers*(self: Module, chatId: string, pubKeys: string) =
  self.controller.addGroupMembers(chatId, self.convertPubKeysToJson(pubKeys))

method removeMemberFromGroupChat*(self: Module, chatId: string, pubKey: string) =
  self.controller.removeMemberFromGroupChat(chatId, pubKey)

method renameGroupChat*(self: Module, chatId: string, newName: string) =
  self.controller.renameGroupChat(chatId, newName)

method makeAdmin*(self: Module, chatId: string, pubKey: string) =
  self.controller.makeAdmin(chatId, pubKey)

method createGroupChat*(self: Module, groupName: string, pubKeys: string) =
  self.controller.createGroupChat(groupName, self.convertPubKeysToJson(pubKeys))

method joinGroup*(self: Module) =
  self.controller.joinGroup()

method joinGroupChatFromInvitation*(self: Module, groupName: string, chatId: string, adminPK: string) =
  self.controller.joinGroupChatFromInvitation(groupName, chatId, adminPK)

method onChatRenamed*(self: Module, chatId: string, newName: string) =
  self.view.chatsModel().renameItem(chatId, newName)

method reorderChannels*(self: Module, chatId, categoryId: string, position: int) =
  self.view.chatsModel().reorder(chatId, categoryId, position)

method acceptRequestToJoinCommunity*(self: Module, requestId: string) =
  self.controller.acceptRequestToJoinCommunity(requestId)

method declineRequestToJoinCommunity*(self: Module, requestId: string) =
  self.controller.declineRequestToJoinCommunity(requestId)

method createCommunityChannel*(self: Module, name, description, categoryId: string) =
  self.controller.createCommunityChannel(name, description, categoryId)

method editCommunityChannel*(self: Module, channelId, name, description, categoryId: string,
  position: int) =
  self.controller.editCommunityChannel(channelId, name, description, categoryId, position)

method createCommunityCategory*(self: Module, name: string, channels: seq[string]) =
  self.controller.createCommunityCategory(name, channels)

method editCommunityCategory*(self: Module, categoryId: string, name: string, channels: seq[string]) =
  self.controller.editCommunityCategory(categoryId, name, channels)

method deleteCommunityCategory*(self: Module, categoryId: string) =
  self.controller.deleteCommunityCategory(categoryId)

method leaveCommunity*(self: Module) =
  self.controller.leaveCommunity()

method editCommunity*(self: Module, name: string, description: string, 
                        access: int, ensOnly: bool, color: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int) =
  self.controller.editCommunity(name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY)

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
    let c = self.controller.getChatDetails(communityId, chat.id)
    let item = initItem(c.id, c.name, "", false, c.color, c.description, c.chatType.int, false, 
                        false, 0, c.muted, active = false, c.position, "")
    self.view.editCategoryChannelsModel().appendItem(item)
  let catChats = self.controller.getChats(communityId, categoryId)
  for chat in catChats:
    let c = self.controller.getChatDetails(communityId, chat.id)
    let item = initItem(c.id, c.name, "", false, c.color, c.description, c.chatType.int, false, 
                        false, 0, c.muted, active = false, c.position, categoryId)
    self.view.editCategoryChannelsModel().appendItem(item)