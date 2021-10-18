import ./dto/community as community_dto

export community_dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunities*(self: ServiceInterface): seq[CommunityDto] {.base.} =
  raise newException(ValueError, "No implementation available")
