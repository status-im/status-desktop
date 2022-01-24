import Tables, stint
import ./controller_interface
import ./io_interface

import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/contacts/service as contacts_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    communityService: community_service.Service
    contactsService: contacts_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service,
    contactsService: contacts_service.Service
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.communityService = communityService
  result.contactsService = contactsService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_COMMUNITY_CREATED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.addCommunity(args.community)

  self.events.on(SIGNAL_COMMUNITY_MY_REQUEST_ADDED) do(e:Args):
    let args = CommunityRequestArgs(e)
    # self.delegate.requestAdded()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_EDITED) do(e:Args):
    let args = CommunityChatArgs(e)
    # self.delegate.communityChannelEdited()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_REORDERED) do(e:Args):
    let args = CommunityChatOrderArgs(e)
    # self.delegate.communityChannelReordered()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_DELETED) do(e:Args):
    let args = CommunityChatIdArgs(e)
    # self.delegate.communityChannelDeleted()

  self.events.on(SIGNAL_COMMUNITY_CATEGORY_CREATED) do(e:Args):
    let args = CommunityCategoryArgs(e)
    # self.delegate.communityCategoryCreated()

  self.events.on(SIGNAL_COMMUNITY_CATEGORY_EDITED) do(e:Args):
    let args = CommunityCategoryArgs(e)
    # self.delegate.communityCategoryEdited()

  self.events.on(SIGNAL_COMMUNITY_CATEGORY_DELETED) do(e:Args):
    let args = CommunityCategoryArgs(e)
    # self.delegate.communityCategoryDeleted()

method getAllCommunities*(self: Controller): seq[CommunityDto] =
  result = self.communityService.getAllCommunities()

method joinCommunity*(self: Controller, communityId: string): string =
  self.communityService.joinCommunity(communityId)

method requestToJoinCommunity*(self: Controller, communityId: string, ensName: string) =
  self.communityService.requestToJoinCommunity(communityId, ensName)

method createCommunity*(
    self: Controller,
    name: string,
    description: string,
    access: int,
    ensOnly: bool,
    color: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int) =
  self.communityService.createCommunity(
    name,
    description,
    access,
    ensOnly,
    color,
    imageUrl,
    aX, aY, bX, bY)

method editCommunityChannel*(
    self: Controller,
    communityId: string,
    channelId: string,
    name: string,
    description: string,
    categoryId: string,
    position: int) =
  self.communityService.editCommunityChannel(
    communityId,
    channelId,
    name,
    description,
    categoryId,
    position)

method reorderCommunityChat*(
    self: Controller,
    communityId: string,
    categoryId: string,
    chatId: string,
    position: int) =
  self.communityService.reorderCommunityChat(
    communityId,
    categoryId,
    chatId,
    position)

method deleteCommunityChat*(
    self: Controller,
    communityId: string,
    chatId: string) =
  self.communityService.deleteCommunityChat(communityId, chatId)

method createCommunityCategory*(
    self: Controller,
    communityId: string,
    name: string,
    channels: seq[string]) =
  self.communityService.createCommunityCategory(communityId, name, channels)

method editCommunityCategory*(
    self: Controller,
    communityId: string,
    categoryId: string,
    name: string,
    channels: seq[string]) =
  self.communityService.editCommunityCategory(communityId, categoryId, name, channels)

method deleteCommunityCategory*(
    self: Controller,
    communityId: string,
    categoryId: string) =
  self.communityService.deleteCommunityCategory(communityId, categoryId)

method requestCommunityInfo*(self: Controller, communityId: string) =
  self.communityService.requestCommunityInfo(communityId)

method importCommunity*(self: Controller, communityKey: string) =
  self.communityService.importCommunity(communityKey)

method removeUserFromCommunity*(self: Controller, communityId: string, pubKeys: string) =
  self.communityService.removeUserFromCommunity(communityId, pubKeys)

method banUserFromCommunity*(self: Controller, communityId: string, pubKey: string) =
  self.communityService.removeUserFromCommunity(communityId, pubKey)

method setCommunityMuted*(self: Controller, communityId: string, muted: bool) =
  self.communityService.setCommunityMuted(communityId, muted)

method getContactNameAndImage*(self: Controller, contactId: string): 
    tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactsService.getContactNameAndImage(contactId)