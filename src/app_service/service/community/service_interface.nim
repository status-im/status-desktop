import std/algorithm
import ./dto/community as community_dto

export community_dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getJoinedCommunities*(self: ServiceInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method loadAllCommunities*(self: ServiceInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method loadJoinedComunities*(self: ServiceInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunityById*(self: ServiceInterface, communityId: string): CommunityDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunityIds*(self: ServiceInterface): seq[string] {.base.} =
  raise newException(ValueError, "No implementation available")

method getCategories*(self: ServiceInterface, communityId: string, order: SortOrder = SortOrder.Ascending): seq[Category] 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method getChats*(self: ServiceInterface, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[Chat] 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllChats*(self: ServiceInterface, communityId: string, order = SortOrder.Ascending): seq[Chat] {.base.} =
  raise newException(ValueError, "No implementation available")

method isUserMemberOfCommunity*(self: ServiceInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method userCanJoin*(self: ServiceInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinCommunity*(self: ServiceInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestToJoinCommunity*(self: ServiceInterface, communityId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadMyPendingRequestsToJoin*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveCommunity*(self: ServiceInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunity*(self: ServiceInterface, name: string, description: string, access: int, ensOnly: bool, color: string, imageUrl: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityChannel*(self: ServiceInterface, communityId: string, name: string, description: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityChannel*(self: ServiceInterface, communityId: string, channelId: string, name: string, description: string, categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChat*(self: ServiceInterface, communityId: string, categoryId: string, chatId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityChat*(self: ServiceInterface, communityId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityCategory*(self: ServiceInterface, communityId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityCategory*(self: ServiceInterface, communityId: string, categoryId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: ServiceInterface, communityId: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestCommunityInfo*(self: ServiceInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method importCommunity*(self: ServiceInterface, communityKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method exportCommunity*(self: ServiceInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")