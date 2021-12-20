import Tables, stint
import eventemitter
import ./controller_interface
import ./io_interface

import ../../../../app/core/signals/types
import ../../../../app_service/service/community/service as community_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    communityService: community_service.Service

proc newController*[T](
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service
    ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.events = events
  result.communityService = communityService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  let communities = self.communityService.getAllCommunities()
  self.delegate.setAllCommunities(communities)

  self.events.on(SIGNAL_COMMUNITY_MY_REQUEST_ADDED) do(e:Args):
    let args = CommunityRequestArgs(e)
    self.delegate.requestAdded()

  self.events.on(SIGNAL_COMMUNITY_LEFT) do(e:Args):
    let args = CommunityIdArgs(e)
    self.delegate.communityLeft(args.communityId)

  self.events.on(SIGNAL_COMMUNITY_CREATED) do(e:Args):
    let args = CommunityArgs(e)
    self.delegate.communityCreated()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_CREATED) do(e:Args):
    let args = CommunityChatArgs(e)
    self.delegate.communityChannelCreated()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_EDITED) do(e:Args):
    let args = CommunityChatArgs(e)
    self.delegate.communityChannelEdited()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_REORDERED) do(e:Args):
    let args = CommunityChatOrderArgs(e)
    self.delegate.communityChannelReordered()

  self.events.on(SIGNAL_COMMUNITY_CHANNEL_DELETED) do(e:Args):
    let args = CommunityChatIdArgs(e)
    self.delegate.communityChannelDeleted()

  self.events.on(SIGNAL_COMMUNITY_CATEGORY_CREATED) do(e:Args):
    let args = CommunityCategoryArgs(e)
    self.delegate.communityCategoryCreated()

  self.events.on(SIGNAL_COMMUNITY_CATEGORY_EDITED) do(e:Args):
    let args = CommunityCategoryArgs(e)
    self.delegate.communityCategoryEdited()

  self.events.on(SIGNAL_COMMUNITY_CATEGORY_DELETED) do(e:Args):
    let args = CommunityCategoryArgs(e)
    self.delegate.communityCategoryDeleted()

method joinCommunity*[T](self: Controller[T], communityId: string): string =
  self.communityService.joinCommunity(communityId)

method requestToJoinCommunity*[T](self: Controller[T], communityId: string, ensName: string) =
  self.communityService.requestToJoinCommunity(communityId, ensName)

method leaveCommunity*[T](self: Controller[T], communityId: string) =
  self.communityService.leaveCommunity(communityId)

method createCommunity*[T](
    self: Controller[T],
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

method createCommunityChannel*[T](
    self: Controller[T],
    communityId: string,
    name: string,
    description: string) =
  self.communityService.createCommunityChannel(communityId, name, description)

method editCommunityChannel*[T](
    self: Controller[T],
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

method reorderCommunityChat*[T](
    self: Controller[T],
    communityId: string,
    categoryId: string,
    chatId: string,
    position: int) =
  self.communityService.reorderCommunityChat(
    communityId,
    categoryId,
    chatId,
    position)

method deleteCommunityChat*[T](
    self: Controller[T],
    communityId: string,
    chatId: string) =
  self.communityService.deleteCommunityChat(communityId, chatId)

method createCommunityCategory*[T](
    self: Controller[T],
    communityId: string,
    name: string,
    channels: seq[string]) =
  self.communityService.createCommunityCategory(communityId, name, channels)

method editCommunityCategory*[T](
    self: Controller[T],
    communityId: string,
    categoryId: string,
    name: string,
    channels: seq[string]) =
  self.communityService.editCommunityCategory(communityId, categoryId, name, channels)

method deleteCommunityCategory*[T](
    self: Controller[T],
    communityId: string,
    categoryId: string) =
  self.communityService.deleteCommunityCategory(communityId, categoryId)

method requestCommunityInfo*[T](self: Controller[T], communityId: string) =
  self.communityService.requestCommunityInfo(communityId)

method importCommunity*[T](self: Controller[T], communityKey: string) =
  self.communityService.importCommunity(communityKey)

method exportCommunity*[T](self: Controller[T], communityId: string): string =
  self.communityService.exportCommunity(communityId)

method acceptRequestToJoinCommunity*[T](self: Controller[T], communityId: string, requestId: string) =
  self.communityService.acceptRequestToJoinCommunity(communityId, requestId)

method declineRequestToJoinCommunity*[T](self: Controller[T], communityId: string, requestId: string) =
  self.communityService.declineRequestToJoinCommunity(communityId, requestId)

method inviteUsersToCommunityById*[T](self: Controller[T], communityId: string, pubKeys: string) =
  self.communityService.inviteUsersToCommunityById(communityId, pubKeys)

method removeUserFromCommunity*[T](self: Controller[T], communityId: string, pubKeys: string) =
  self.communityService.removeUserFromCommunity(communityId, pubKeys)

method banUserFromCommunity*[T](self: Controller[T], communityId: string, pubKey: string) =
  self.communityService.removeUserFromCommunity(communityId, pubKey)

method setCommunityMuted*[T](self: Controller[T], communityId: string, muted: bool) =
  self.communityService.setCommunityMuted(communityId, muted)
