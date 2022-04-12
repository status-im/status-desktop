import Tables, stint
import ./io_interface

import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/contacts/service as contacts_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    communityService: community_service.Service
    contactsService: contacts_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service,
    contactsService: contacts_service.Service,
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.communityService = communityService
  result.contactsService = contactsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_COMMUNITY_CREATED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityAdded(args.community)

  self.events.on(SIGNAL_COMMUNITY_DATA_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityAdded(args.community)

  self.events.on(SIGNAL_COMMUNITY_ADDED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityAdded(args.community)

  self.events.on(SIGNAL_COMMUNITY_IMPORTED) do(e:Args):
    let args = CommunityArgs(e)
    if(args.error.len > 0):
      self.delegate.onImportCommunityErrorOccured(args.error)
    else:
      self.delegate.communityImported(args.community)

  self.events.on(SIGNAL_COMMUNITIES_UPDATE) do(e:Args):
    let args = CommunitiesArgs(e)
    for community in args.communities:
      self.delegate.communityEdited(community)

proc getAllCommunities*(self: Controller): seq[CommunityDto] =
  result = self.communityService.getAllCommunities()

proc joinCommunity*(self: Controller, communityId: string): string =
  self.communityService.joinCommunity(communityId)

proc requestToJoinCommunity*(self: Controller, communityId: string, ensName: string) =
  self.communityService.requestToJoinCommunity(communityId, ensName)

proc createCommunity*(
    self: Controller,
    name: string,
    description: string,
    access: int,
    ensOnly: bool,
    color: string,
    imageUrl: string,
    aX: int, aY: int, bX: int, bY: int,
    historyArchiveSupportEnabled: bool) =
  self.communityService.createCommunity(
    name,
    description,
    access,
    ensOnly,
    color,
    imageUrl,
    aX, aY, bX, bY,
    historyArchiveSupportEnabled)

proc reorderCommunityChat*(
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

proc deleteCommunityChat*(
    self: Controller,
    communityId: string,
    chatId: string) =
  self.communityService.deleteCommunityChat(communityId, chatId)

proc deleteCommunityCategory*(
    self: Controller,
    communityId: string,
    categoryId: string) =
  self.communityService.deleteCommunityCategory(communityId, categoryId)

proc requestCommunityInfo*(self: Controller, communityId: string) =
  self.communityService.requestCommunityInfo(communityId)

proc importCommunity*(self: Controller, communityKey: string) =
  self.communityService.importCommunity(communityKey)

proc setCommunityMuted*(self: Controller, communityId: string, muted: bool) =
  self.communityService.setCommunityMuted(communityId, muted)

proc getContactNameAndImage*(self: Controller, contactId: string):
    tuple[name: string, image: string] =
  return self.contactsService.getContactNameAndImage(contactId)

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactsService.getContactDetails(contactId)

proc isUserMemberOfCommunity*(self: Controller, communityId: string): bool =
  return self.communityService.isUserMemberOfCommunity(communityId)

proc userCanJoin*(self: Controller, communityId: string): bool =
  return self.communityService.userCanJoin(communityId)

proc isCommunityRequestPending*(self: Controller, communityId: string): bool =
  return self.communityService.isCommunityRequestPending(communityId)
