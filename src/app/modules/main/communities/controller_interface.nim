import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/visual_identity/service as visual_identity_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllCommunities*(self: AccessInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method joinCommunity*(self: AccessInterface, communityId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method requestToJoinCommunity*(self: AccessInterface, communityId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunity*(self: AccessInterface, name: string, description: string, access: int, ensOnly: bool, color: string, imageUrl: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityChannel*(self: AccessInterface, communityId: string, chatId: string, name: string, description: string, categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChat*(self: AccessInterface, communityId: string, categoryId: string, chatId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityChat*(self: AccessInterface, communityId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: AccessInterface, communityId: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestCommunityInfo*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method isUserMemberOfCommunity*(self: AccessInterface, communityId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method userCanJoin*(self: AccessInterface, communityId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isCommunityRequestPending*(self: AccessInterface, communityId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method importCommunity*(self: AccessInterface, communityKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method banUserFromCommunity*(self: AccessInterface, communityId: string, pubKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setCommunityMuted*(self: AccessInterface, communityId: string, muted: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactNameAndImage*(self: AccessInterface, contactId: string):
    tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetails*(self: AccessInterface, contactId: string): ContactDetails {.base.} =
  raise newException(ValueError, "No implementation available")

method getEmojiHash*(self: AccessInterface, pubkey: string): EmojiHashDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getColorHash*(self: AccessInterface, pubkey: string): ColorHashDto {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
