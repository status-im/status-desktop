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

method getCommunities*(self: ServiceInterface): seq[CommunityDto] {.base.} =
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