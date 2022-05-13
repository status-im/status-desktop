import Tables, chronicles
import io_interface

import ../../../../global/app_signals
import ../../../../core/eventemitter
import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/community/service as community_service

logScope:
  topics = "profile-section-notifications-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    chatService: chat_service.Service
    contactService: contact_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  chatService: chat_service.Service,
  contactService: contact_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.chatService = chatService
  result.contactService = contactService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(TOGGLE_SECTION) do(e:Args):
    let args = ToggleSectionArgs(e)
    self.delegate.onToggleSection(args.sectionType)

  self.events.on(SIGNAL_COMMUNITY_JOINED) do(e:Args):
    let args = CommunityArgs(e)
    if(args.error.len > 0):
      return
    self.delegate.addCommunity(args.community)

  self.events.on(SIGNAL_COMMUNITY_CREATED) do(e:Args):
    let args = CommunityArgs(e)
    if(args.error.len > 0):
      return
    self.delegate.addCommunity(args.community)

  self.events.on(SIGNAL_COMMUNITY_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    if(args.error.len > 0):
      return
    self.delegate.addCommunity(args.community)

  self.events.on(SIGNAL_COMMUNITY_LEFT) do(e:Args):
    let args = CommunityIdArgs(e)
    self.delegate.removeItemWithId(args.communityId)

  self.events.on(SIGNAL_COMMUNITY_EDITED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.editCommunity(args.community)

  self.events.on(SIGNAL_COMMUNITIES_UPDATE) do(e:Args):
    let args = CommunitiesArgs(e)
    for community in args.communities:
      self.delegate.editCommunity(community)
  
  self.events.on(chat_service.SIGNAL_CHAT_ADDED_OR_UPDATED) do(e: Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.addChat(args.chatId)

  self.events.on(chat_service.SIGNAL_CHAT_LEFT) do(e: Args):
    let args = chat_service.ChatArgs(e)
    self.delegate.removeItemWithId(args.chatId)

  self.events.on(SIGNAL_CHAT_UPDATE) do(e: Args):
    var args = ChatUpdateArgsNew(e)
    for chat in args.chats:
      let belongsToCommunity = chat.communityId.len > 0
      self.delegate.addChat(chat)

  self.events.on(SIGNAL_CHAT_RENAMED) do(e: Args):
    var args = ChatRenameArgs(e)
    self.delegate.setName(args.id, args.newName)

  self.events.on(SIGNAL_CHAT_SWITCH_TO_OR_CREATE_1_1_CHAT) do(e:Args):
    let args = ChatExtArgs(e)
    self.delegate.addChat(args.chatId)

proc getChannelGroups*(self: Controller): seq[ChannelGroupDto] =
  return self.chatService.getChannelGroups()

proc getChatDetails*(self: Controller, chatId: string): ChatDto =
  return self.chatService.getChatById(chatId)
  
proc getContactDetails*(self: Controller, id: string): ContactDetails =
  return self.contactService.getContactDetails(id)