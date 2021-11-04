import NimQml, Tables, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, item, sub_item, model, sub_model
import ../../../core/global_singleton

import chat_content/module as chat_content_module

import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service

import eventemitter

export io_interface

logScope:
  topics = "chat-section-module"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatContentModule: OrderedTable[string, chat_content_module.AccessInterface]
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, id: string, isCommunity: bool, 
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, id, isCommunity, chatService, communityService, messageService)
  result.moduleLoaded = false
  
  result.chatContentModule = initOrderedTable[string, chat_content_module.AccessInterface]()

method delete*(self: Module) =
  for cModule in self.chatContentModule.values:
    cModule.delete
  self.chatContentModule.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc addSubmodule(self: Module, chatId: string, belongToCommunity: bool, events: EventEmitter, 
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service) =
  self.chatContentModule[chatId] = chat_content_module.newModule(self, events, chatId, belongToCommunity, chatService, 
      communityService, messageService)

proc buildChatUI(self: Module, events: EventEmitter, chatService: chat_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service) =
  let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat, ChatType.Profile]
  let chats = self.controller.getChatDetailsForChatTypes(types)

  var selectedItemId = ""
  for c in chats:
    let hasNotification = c.unviewedMessagesCount > 0 or c.unviewedMentionsCount > 0
    let notificationsCount = c.unviewedMentionsCount
    let item = initItem(c.id, if c.alias.len > 0: c.alias else: c.name, c.identicon, c.color, c.description, 
    c.chatType.int, hasNotification, notificationsCount, c.muted, false)
    self.view.appendItem(item)
    self.addSubmodule(c.id, false, events, chatService, communityService, messageService)
    
    # make the first Public chat active when load the app
    if(selectedItemId.len == 0 and c.chatType == ChatType.Public):
      selectedItemId = item.id

  self.setActiveItemSubItem(selectedItemId, "")

proc buildCommunityUI(self: Module, events: EventEmitter, chatService: chat_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service) =
  var selectedItemId = ""
  var selectedSubItemId = ""
  let communityIds = self.controller.getCommunityIds()
  for cId in communityIds:
    # handle channels which don't belong to any category
    let chats = self.controller.getChats(cId, "")
    for c in chats:
      let chatDto = self.controller.getChatDetails(cId, c.id)

      let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
      let notificationsCount = chatDto.unviewedMentionsCount
      let channelItem = initItem(chatDto.id, if chatDto.alias.len > 0: chatDto.alias else: chatDto.name, 
      chatDto.identicon, chatDto.color, chatDto.description, chatDto.chatType.int, hasNotification, notificationsCount, 
      chatDto.muted, false)
      self.view.appendItem(channelItem)
      self.addSubmodule(chatDto.id, true, events, chatService, communityService, messageService)

      # make the first channel which doesn't belong to any category active when load the app
      if(selectedItemId.len == 0):
        selectedItemId = channelItem.id

    # handle categories and channels for each category
    let categories = self.controller.getCategories(cId)
    for cat in categories:
      var hasNotificationPerCategory = false
      var notificationsCountPerCategory = 0
      var categoryChannels: seq[SubItem]

      let categoryChats = self.controller.getChats(cId, cat.id)
      for c in categoryChats:
        let chatDto = self.controller.getChatDetails(cId, c.id)
        
        let hasNotification = chatDto.unviewedMessagesCount > 0 or chatDto.unviewedMentionsCount > 0
        let notificationsCount = chatDto.unviewedMentionsCount

        hasNotificationPerCategory = hasNotificationPerCategory or hasNotification
        notificationsCountPerCategory += notificationsCount

        let channelItem = initSubItem(chatDto.id, if chatDto.alias.len > 0: chatDto.alias else: chatDto.name, 
        chatDto.identicon, chatDto.color, chatDto.description, hasNotification, notificationsCount, chatDto.muted, 
        false)
        categoryChannels.add(channelItem)
        self.addSubmodule(chatDto.id, true, events, chatService, communityService, messageService)

        # in case there is no channels beyond categories, 
        # make the first channel of the first category active when load the app
        if(selectedItemId.len == 0):
          selectedItemId = cat.id
          selectedSubItemId = channelItem.id

      var categoryItem = initItem(cat.id, cat.name, "", "", "", ChatType.Unknown.int, hasNotificationPerCategory, 
      notificationsCountPerCategory, false, false)
      categoryItem.prependSubItems(categoryChannels)
      self.view.appendItem(categoryItem)

  self.setActiveItemSubItem(selectedItemId, selectedSubItemId)

method load*(self: Module, events: EventEmitter, chatService: chat_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service) =
  self.controller.init()
  self.view.load()
  
  if(self.controller.isCommunity()):
    self.buildCommunityUI(events, chatService, communityService, messageService)
  else:
    self.buildChatUI(events, chatService, communityService, messageService)

  for cModule in self.chatContentModule.values:
    cModule.load()

proc checkIfModuleDidLoad(self: Module) =
  if self.moduleLoaded:
    return

  for cModule in self.chatContentModule.values:
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

method activeItemSubItemSet*(self: Module, itemId: string, subItemId: string) =
  let item = self.view.model().getItemById(itemId)
  if(item.isNil):
    # Should never be here
    error "chat-view unexisting item id: ", itemId
    return

  # Chats from Chat section and chats from Community section which don't belong 
  # to any category have empty `subItemId`
  let subItem = item.subItems.getItemById(subItemId)
  
  self.view.model().setActiveItemSubItem(itemId, subItemId)
  self.view.activeItemSubItemSet(item, subItem)

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getChatContentModule*(self: Module, chatId: string): QVariant =
  if(not self.chatContentModule.contains(chatId)):
    error "unexisting chat key: ", chatId
    return

  return self.chatContentModule[chatId].getModuleAsVariant()