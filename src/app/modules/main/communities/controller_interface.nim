import ../../../../app_service/service/community/service as community_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method joinCommunity*(self: AccessInterface, communityId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method requestToJoinCommunity*(self: AccessInterface, communityId: string, ensName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveCommunity*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunity*(self: AccessInterface, name: string, description: string, access: int, ensOnly: bool, color: string, imageUrl: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityChannel*(self: AccessInterface, communityId: string, name: string, description: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityChannel*(self: AccessInterface, communityId: string, chatId: string, name: string, description: string, categoryId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method reorderCommunityChat*(self: AccessInterface, communityId: string, categoryId: string, chatId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityChat*(self: AccessInterface, communityId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method createCommunityCategory*(self: AccessInterface, communityId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method editCommunityCategory*(self: AccessInterface, communityId: string, categoryId: string, name: string, channels: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteCommunityCategory*(self: AccessInterface, communityId: string, categoryId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestCommunityInfo*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method importCommunity*(self: AccessInterface, communityKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method exportCommunity*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
