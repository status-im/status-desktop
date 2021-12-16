import ../../../../app_service/service/community/service as community_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method setAllCommunities*(self: AccessInterface, communities: seq[CommunityDto]) {.base.} =
  raise newException(ValueError, "No implementation available") 

method joinCommunity*(self: AccessInterface, communityId: string): string {.base.} =
  raise newException(ValueError, "No implementation available") 

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    c.communitiesModuleDidLoad()
