import NimQml
import json, strutils, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller
import location_menu_model, location_menu_item
import location_menu_sub_model, location_menu_sub_item
import result_model, result_item
import ../../shared_models/message_item

import ../../../global/global_singleton
import ../../../global/app_sections_config as conf
import ../../../core/eventemitter
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service

export io_interface

logScope:
  topics = "app-search-module"

# Constants used in this module
const SEARCH_MENU_LOCATION_CHAT_SECTION_NAME = "Chat"
const SEARCH_RESULT_COMMUNITIES_SECTION_NAME = "Communities"
const SEARCH_RESULT_CHATS_SECTION_NAME = "Chats"
const SEARCH_RESULT_CHANNELS_SECTION_NAME = "Channels"
const SEARCH_RESULT_MESSAGES_SECTION_NAME = "Messages"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, contactsService: contact_service.Service, 
  chatService: chat_service.Service, communityService: community_service.Service, messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, contactsService, chatService, communityService, 
  messageService)
  result.moduleLoaded = false
  
method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.appSearchDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

proc buildLocationMenuForChat(self: Module): location_menu_item.Item =
  var item = location_menu_item.initItem(conf.CHAT_SECTION_ID, SEARCH_MENU_LOCATION_CHAT_SECTION_NAME, "", "chat", "", 
  false)

  let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
  let displayedChats = self.controller.getChatDetailsForChatTypes(types)

  var subItems: seq[location_menu_sub_item.SubItem]
  for c in displayedChats:
    var chatName = c.name
    var chatImage = c.identicon
    var isIdenticon = false
    if(c.chatType == ChatType.OneToOne):
      (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(c.id)

    let subItem = location_menu_sub_item.initSubItem(c.id, chatName, chatImage, "", c.color, isIdenticon)
    subItems.add(subItem)
    
  item.setSubItems(subItems)
  return item

proc buildLocationMenuForCommunity(self: Module, community: CommunityDto): location_menu_item.Item =
  var item = location_menu_item.initItem(community.id, community.name, community.images.thumbnail, "", community.color,
  community.images.thumbnail.len == 0)

  var subItems: seq[location_menu_sub_item.SubItem]
  let chats = self.controller.getAllChatsForCommunity(community.id)
  for c in chats:
    let chatDto = self.controller.getChatDetails(community.id, c.id)
    let subItem = location_menu_sub_item.initSubItem(chatDto.id, chatDto.name, chatDto.identicon, "", chatDto.color, 
    chatDto.identicon.len == 0)
    subItems.add(subItem)

  item.setSubItems(subItems)
  return item

method prepareLocationMenuModel*(self: Module) =
  var items: seq[location_menu_item.Item]
  items.add(self.buildLocationMenuForChat())
  
  let communities = self.controller.getJoinedCommunities()
  for c in communities:
    items.add(self.buildLocationMenuForCommunity(c))

  self.view.locationMenuModel().setItems(items)

method onActiveChatChange*(self: Module, sectionId: string, chatId: string) =
  self.controller.setActiveSectionIdAndChatId(sectionId, chatId)

method setSearchLocation*(self: Module, location: string, subLocation: string) =
  self.controller.setSearchLocation(location, subLocation)

method getSearchLocationObject*(self: Module): string = 
  ## This method returns location and subLocation with their details so we
  ## may set initial search location on the side of qml.
  var jsonObject = %* {
    "location": "", 
    "subLocation": ""
  }

  if(self.controller.activeSectionId().len == 0):
    return Json.encode(jsonObject)

  let item = self.view.locationMenuModel().getItemForValue(self.controller.activeSectionId())
  if(not item.isNil):
    jsonObject["location"] = item.toJsonNode()

    if(self.controller.activeChatId().len > 0):
      let subItem = item.getSubItemForValue(self.controller.activeChatId())
      if(not subItem.isNil):
        jsonObject["subLocation"] = subItem.toJsonNode()

  return Json.encode(jsonObject)

method searchMessages*(self: Module, searchTerm: string) =
  if (searchTerm.len == 0):
    self.view.searchResultModel().clear()
    return
  
  self.controller.searchMessages(searchTerm)

method onSearchMessagesDone*(self: Module, messages: seq[MessageDto]) =
  var items: seq[result_item.Item]
  var channels: seq[result_item.Item]

  # Add communities
  let communities = self.controller.getJoinedCommunities()
  for co in communities:
    if(self.controller.searchLocation().len == 0 and co.name.toLower.startsWith(self.controller.searchTerm().toLower)):
      let item = result_item.initItem(co.id, "", "", co.id, co.name, SEARCH_RESULT_COMMUNITIES_SECTION_NAME, 
        co.images.thumbnail, co.color, "", "", co.images.thumbnail, co.color, false)

      items.add(item)

    # Add channels
    if(self.controller.searchSubLocation().len == 0 and self.controller.searchLocation().len == 0 or
      self.controller.searchLocation() == co.id):
      for c in co.chats:
        let chatDto = self.controller.getChatDetails(co.id, c.id)
        if(c.name.toLower.startsWith(self.controller.searchTerm().toLower)):
          let item = result_item.initItem(chatDto.id, "", "", chatDto.id, chatDto.name, 
          SEARCH_RESULT_CHANNELS_SECTION_NAME, chatDto.identicon, chatDto.color, "", "", chatDto.identicon, chatDto.color, 
          false)

          channels.add(item)

  # Add chats
  if(self.controller.searchLocation().len == 0 or self.controller.searchLocation() == conf.CHAT_SECTION_ID and
    self.controller.searchSubLocation().len == 0):
    let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
    let displayedChats = self.controller.getChatDetailsForChatTypes(types)

    for c in displayedChats:
      var chatName = c.name
      var chatImage = c.identicon
      var isIdenticon = false
      if(c.chatType == ChatType.OneToOne):
        (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(c.id)

      var rawChatName = chatName
      if(chatName.startsWith("@")):
        rawChatName = chatName[1 ..^ 1]

      if(rawChatName.toLower.startsWith(self.controller.searchTerm().toLower)):
        let item = result_item.initItem(c.id, "", "", c.id, chatName, SEARCH_RESULT_CHATS_SECTION_NAME, chatImage, 
        c.color, "", "", chatImage, c.color, isIdenticon)

        items.add(item)

  # Add channels in order as requested by the design
  items.add(channels)

  # Add messages
  for m in messages:
    if (m.contentType.ContentType != ContentType.Message):
      continue

    let chatDto = self.controller.getChatDetails("", m.chatId)
    var (senderName, senderImage, senderIsIdenticon) = self.controller.getContactNameAndImage(m.`from`)
    if(m.`from` == singletonInstance.userProfile.getPubKey()):
      senderName = "You"
      
    if(chatDto.communityId.len == 0):
      var chatName = chatDto.name
      var chatImage = chatDto.identicon
      var isIdenticon = false
      if(chatDto.chatType == ChatType.OneToOne):
        (chatName, chatImage, isIdenticon) = self.controller.getOneToOneChatNameAndImage(chatDto.id)

      let item = result_item.initItem(m.id, m.text, $m.timestamp, m.`from`, senderName, 
      SEARCH_RESULT_MESSAGES_SECTION_NAME, senderImage, "", chatName, "", chatImage, chatDto.color, isIdenticon)

      items.add(item)
    else:
      let community = self.controller.getCommunityById(chatDto.communityId)
      let channelName = "#" & chatDto.name

      let item = result_item.initItem(m.id, m.text, $m.timestamp, m.`from`, senderName, 
      SEARCH_RESULT_MESSAGES_SECTION_NAME, senderImage, "", community.name, channelName, community.images.thumbnail, 
      community.color, false)

      items.add(item)

  self.view.searchResultModel().set(items)
