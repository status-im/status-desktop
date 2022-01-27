import Tables, controller_interface, chronicles
import io_interface

import ../../../global/app_sections_config as conf
import ../../../../app_service/service/contacts/service as contact_service
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service

import ../../../core/signals/types
import ../../../core/eventemitter

export controller_interface

logScope:
  topics = "app-search-module-controller"

type ResultItemDetails = object
  sectionId*: string
  channelId*: string
  messageId*: string

method isEmpty(self: ResultItemDetails): bool =
  self.sectionId.len == 0 and 
  self.channelId.len == 0 and 
  self.messageId.len == 0

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    contactsService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service
    activeSectionId: string
    activeChatId: string
    searchLocation: string
    searchSubLocation: string
    searchTerm: string
    resultItems: Table[string, ResultItemDetails] # [resultItemId, ResultItemDetails]

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, contactsService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.contactsService = contactsService
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  result.resultItems = initTable[string, ResultItemDetails]()
  
method delete*(self: Controller) =
  self.resultItems.clear

method init*(self: Controller) = 
  self.events.on(SIGNAL_SEARCH_MESSAGES_LOADED) do(e:Args):
    let args = MessagesArgs(e)
    self.delegate.onSearchMessagesDone(args.messages)

method activeSectionId*(self: Controller): string =
  return self.activeSectionId

method activeChatId*(self: Controller): string =
  return self.activeChatId

method setActiveSectionIdAndChatId*(self: Controller, sectionId: string, chatId: string) =
    self.activeSectionId = sectionId
    self.activeChatId = chatId

method searchTerm*(self: Controller): string =
  return self.searchTerm

method searchLocation*(self: Controller): string =
  return self.searchLocation

method searchSubLocation*(self: Controller): string =
  return self.searchSubLocation

method setSearchLocation*(self: Controller, location: string, subLocation: string) = 
    ## Setting location and subLocation to an empty string means we're 
    ## searching in all available chats/channels/communities.
    self.searchLocation = location
    self.searchSubLocation = subLocation

method getJoinedCommunities*(self: Controller): seq[CommunityDto] =
  return self.communityService.getJoinedCommunities()

method getCommunityById*(self: Controller, communityId: string): CommunityDto =
  return self.communityService.getCommunityById(communityId)

method getAllChatsForCommunity*(self: Controller, communityId: string): seq[Chat] =
  return self.communityService.getAllChats(communityId)

method getChatDetailsForChatTypes*(self: Controller, types: seq[ChatType]): seq[ChatDto] =
  return self.chatService.getChatsOfChatTypes(types)

method getChatDetails*(self: Controller, communityId, chatId: string): ChatDto =
  let fullId = communityId & chatId
  return self.chatService.getChatById(fullId)

method searchMessages*(self: Controller, searchTerm: string) =
  self.resultItems.clear
  self.searchTerm = searchTerm

  var chats: seq[string]
  var communities: seq[string]

  if (self.searchSubLocation.len > 0):
    chats.add(self.searchSubLocation)
  elif (self.searchLocation.len > 0):
    # If "Chat" is set for the meassgeSearchLocation that means we need to search in all chats from the chat section.
    if (self.searchLocation != conf.CHAT_SECTION_ID):
      communities.add(self.searchLocation)
    else:
      let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
      let displayedChats = self.getChatDetailsForChatTypes(types)
      for c in displayedChats:
        chats.add(c.id)

  if (communities.len == 0 and chats.len == 0):
    let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
    let displayedChats = self.getChatDetailsForChatTypes(types)
    for c in displayedChats:
      chats.add(c.id)

    let communitiesIds = self.communityService.getCommunityIds()
    for cId in communitiesIds:
      communities.add(cId)

  self.messageService.asyncSearchMessages(communities, chats, self.searchTerm, false)

method getOneToOneChatNameAndImage*(self: Controller, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

method getContactNameAndImage*(self: Controller, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactsService.getContactNameAndImage(contactId)

method addResultItemDetails*(self: Controller, itemId: string, sectionId = "", channelId = "", messageId = "") =
  self.resultItems.add(itemId, ResultItemDetails(sectionId: sectionId, channelId: channelId, messageId: messageId))

method resultItemClicked*(self: Controller, itemId: string) =
  let itemDetails = self.resultItems.getOrDefault(itemId)
  if(itemDetails.isEmpty()):
    # we shouldn't be here ever
    info "important: we don't have stored details for a searched result item with id: ", itemId
    return
  
  self.messageService.switchTo(itemDetails.sectionId, itemDetails.channelId, itemDetails.messageId)