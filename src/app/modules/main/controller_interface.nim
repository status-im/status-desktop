import ../../../app_service/service/community/service_interface as community_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunities*(self: AccessInterface): 
  seq[community_service.CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method checkForStoringPassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method storePassword*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available") 

method updateUserPreferenceForStoreToKeychain*(self: AccessInterface, 
  selection: string) {.base.} =
  raise newException(ValueError, "No implementation available")