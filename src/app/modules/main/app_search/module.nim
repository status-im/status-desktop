import NimQml
import json, strutils, chronicles, sequtils, tables, std/algorithm
import io_interface
import ../io_interface as delegate_interface
import view, controller
import location_menu_model, location_menu_item
import location_menu_sub_item
import result_model, result_item
import ../../shared_models/message_item

import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/visual_identity/service as visual_identity

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
    controller: Controller
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

proc getChatSubItems(self: Module, chats: seq[ChatDto], categories: seq[Category] = @[]): seq[location_menu_sub_item.SubItem] =
  var highestPosition = 0
  var categoryChats: OrderedTable[int, seq[ChatDto]] = initOrderedTable[int, seq[ChatDto]]()

  for chatDto in chats:
    if not chatDto.canView and not chatDto.missingEncryptionKey:
      continue
    
    var chatName = chatDto.name
    var chatImage = chatDto.icon
    var colorHash: ColorHashDto = @[]
    var colorId: int = 0
    let isOneToOneChat = chatDto.chatType == ChatType.OneToOne
    if isOneToOneChat:
      (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(chatDto.id)
      colorHash = self.controller.getColorHash(chatDto.id)
      colorId = self.controller.getColorId(chatDto.id)
    elif chatDto.chatType == ChatType.CommunityChat:
      if chatDto.categoryId != "":
        for cat in categories:
          if cat.id == chatDto.categoryId:
            if not categoryChats.hasKey(cat.position):
              categoryChats[cat.position] = @[]
            categoryChats[cat.position].add(chatDto)
            break
        continue
      else:
        if chatDto.position > highestPosition:
          highestPosition = chatDto.position

    let subItem = location_menu_sub_item.initSubItem(
      chatDto.id,
      chatName,
      image = if (chatImage != ""): chatImage else: chatDto.emoji,
      icon = "",
      chatDto.color,
      isOneToOneChat,
      isImage = chatImage != "",
      chatDto.position,
      chatDto.timestamp.int,
      colorId,
      colorHash,
    )
    result.add(subItem)

  # Add category chats by adjusting the position by taking into account the category position
  let sortedKeys = toSeq(categoryChats.keys).sorted()
  for categoryPosition in sortedKeys:
    highestPosition.inc()
    for chat in categoryChats[categoryPosition]:
      let chatPosition = chat.position + highestPosition
      result.add(location_menu_sub_item.initSubItem(
        chat.id,
        chat.name,
        chat.emoji,
        icon = "",
        chat.color,
        isUserIcon = false,
        isImage = false,
        chatPosition,
        chat.timestamp.int,
      ))
    highestPosition += categoryChats[categoryPosition].len

proc buildLocationMenuForCommunity(self: Module, community: CommunityDto): location_menu_item.Item =
  var item = location_menu_item.initItem(
    community.id,
    community.name,
    community.images.thumbnail,
    icon="",
    community.color
  )

  var subItems = self.getChatSubItems(community.chats, community.categories)
  item.setSubItems(subItems)

  return item

method prepareLocationMenuModel*(self: Module) =
  var items: seq[location_menu_item.Item]

  # Personal Section
  let myPubKey = singletonInstance.userProfile.getPubKey()
  var personalItem = location_menu_item.initItem(
    value = myPubKey,
    text = SEARCH_MENU_LOCATION_CHAT_SECTION_NAME,
    image = "",
    icon = "chat",
  )

  var subItems = self.getChatSubItems(self.controller.getChatsForPersonalSection())
  personalItem.setSubItems(subItems)
  items.add(personalItem)

  # Community sections
  let communities = self.controller.getJoinedAndSpectatedCommunities()
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
    self.view.emitAppSearchCompletedSignal()
    return

  self.controller.searchMessages(searchTerm)

proc getResultItemFromChats(self: Module, sectionId: string, chats: seq[ChatDto], sectionName: string): seq[result_item.Item] =
  if (self.controller.searchSubLocation().len == 0 and self.controller.searchLocation().len == 0) or
      self.controller.searchLocation() == sectionId:
    
    let searchTerm = self.controller.searchTerm().toLower
    for chatDto in chats:
      if chatDto.isHiddenChat:
        continue

      var chatName = chatDto.name
      var chatImage = chatDto.icon
      var colorHash: ColorHashDto = @[]
      var colorId: int = 0
      let isOneToOneChat = chatDto.chatType == ChatType.OneToOne
      if(isOneToOneChat):
        (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(chatDto.id)
        colorHash = self.controller.getColorHash(chatDto.id)
        colorId = self.controller.getColorId(chatDto.id)

      var rawChatName = chatName
      if(chatName.startsWith("@")):
        rawChatName = chatName[1 ..^ 1]

      if rawChatName.toLower.contains(searchTerm):
        let item = result_item.initItem(
          chatDto.id,
          content="",
          time="",
          titleId=chatDto.id,
          title=chatName,
          SEARCH_RESULT_CHANNELS_SECTION_NAME,
          chatImage,
          chatDto.color,
          badgePrimaryText="",
          badgeSecondaryText="",
          chatImage,
          chatDto.color,
          false,
          isOneToOneChat,
          colorId,
          colorHash)

        self.controller.addResultItemDetails(chatDto.id, sectionId, chatDto.id)
        result.add(item)

method onSearchMessagesDone*(self: Module, messages: seq[MessageDto]) =
  var items: seq[result_item.Item]

  # Add Personal section chats
  let myPubKey = singletonInstance.userProfile.getPubKey()
  let personalItems = self.getResultItemFromChats(myPubKey, self.controller.getChatsForPersonalSection(), SEARCH_RESULT_CHATS_SECTION_NAME)
  var channels = personalItems

  # Add Communities
  let communities = self.controller.getJoinedAndSpectatedCommunities()

  let searchTerm = self.controller.searchTerm().toLower
  for community in communities:
    if self.controller.searchLocation().len == 0 and
        community.name.toLower.contains(searchTerm):
      let item = result_item.initItem(
        community.id,
        content="",
        time="",
        titleId=community.id,
        title=community.name,
        SEARCH_RESULT_COMMUNITIES_SECTION_NAME,
        community.images.thumbnail,
        community.color,
        badgePrimaryText="",
        badgeSecondaryText="",
        community.images.thumbnail,
        community.color,
        badgeIsLetterIdenticon=false)

      self.controller.addResultItemDetails(community.id, community.id)
      items.add(item)

    # Add channels
    let communityChatItems = self.getResultItemFromChats(community.id, community.chats, SEARCH_RESULT_CHANNELS_SECTION_NAME)
    if communityChatItems.len > 0:
      channels = channels.concat(channels, communityChatItems)

  # Add channels in order as requested by the design
  items.add(channels)

  # Add messages
  for m in messages:
    if (m.contentType != ContentType.Message):
      continue

    let chatDto = self.controller.getChatDetails("", m.chatId)
    var (senderName, senderImage, _) = self.controller.getContactNameAndImage(m.`from`)
    if(m.`from` == singletonInstance.userProfile.getPubKey()):
      senderName = "You"

    let communityChats = self.controller.getCommunityById(chatDto.communityId).chats

    let renderedMessageText = self.controller.getRenderedText(m.parsedText, communityChats)
    let colorHash = self.controller.getColorHash(m.`from`)
    let colorId = self.controller.getColorId(m.`from`)

    if(chatDto.communityId.len == 0):
      var chatName = chatDto.name
      var chatImage = chatDto.icon
      if(chatDto.chatType == ChatType.OneToOne):
        (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(chatDto.id)
      let item = result_item.initItem(m.id, renderedMessageText, $m.timestamp, m.`from`, senderName,
        SEARCH_RESULT_MESSAGES_SECTION_NAME, senderImage, chatDto.color, chatName, "", chatImage,
        chatDto.color, false, true, colorId, colorHash)

      self.controller.addResultItemDetails(m.id, singletonInstance.userProfile.getPubKey(),
        chatDto.id, m.id)
      items.add(item)
    else:
      let community = self.controller.getCommunityById(chatDto.communityId)
      let channelName = "#" & chatDto.name

      let item = result_item.initItem(m.id, renderedMessageText, $m.timestamp, m.`from`, senderName,
        SEARCH_RESULT_MESSAGES_SECTION_NAME, senderImage, chatDto.color, community.name,
        channelName, community.images.thumbnail, community.color, false, true, colorId, colorHash)

      self.controller.addResultItemDetails(m.id, chatDto.communityId, chatDto.id, m.id)
      items.add(item)

  self.view.searchResultModel().set(items)
  self.view.emitAppSearchCompletedSignal()

method resultItemClicked*(self: Module, itemId: string) =
  self.controller.resultItemClicked(itemId)

method updateSearchLocationIfPointToChatWithId*(self: Module, chatId: string) =
  if self.controller.activeChatId() == chatId:
    self.controller.setSearchLocation(self.controller.activeSectionId(), "")
