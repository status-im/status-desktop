import ../../../../../app_service/service/community/service as community_service
import ../../../shared_models/section_item

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setAllCommunities*(self: AccessInterface, communities: seq[CommunityDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunityItem*(self: AccessInterface, community: CommunityDto): SectionItem {.base.} =
  raise newException(ValueError, "No implementation available")

method joinCommunity*(self: AccessInterface, communityId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunity*(self: AccessInterface, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: AccessInterface, communityId: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityCategories*(self: AccessInterface, communityId: string, categoryId: string, position: int) {.base} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChannel*(self: AccessInterface, communityId: string, categoryId: string, chatId: string, position: int) {.base} =
  raise newException(ValueError, "No implementation available")

method banUserFromCommunity*(self: AccessInterface, pubKey: string, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method isUserMemberOfCommunity*(self: AccessInterface, communityId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method userCanJoin*(self: AccessInterface, communityId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isCommunityRequestPending*(self: AccessInterface, communityId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method requestToJoinCommunity*(self: AccessInterface, communityId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestCommunityInfo*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityChat*(self: AccessInterface, communityId: string, channelId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method importCommunity*(self: AccessInterface, communityKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")
