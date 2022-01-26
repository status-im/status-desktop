
method myRequestAdded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityLeft*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityChannelCreated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityChannelEdited*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityChannelReordered*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityChannelDeleted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityCategoryCreated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityCategoryEdited*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityCategoryDeleted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityEdited*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")