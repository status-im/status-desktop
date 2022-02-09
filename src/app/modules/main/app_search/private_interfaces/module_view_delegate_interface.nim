method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareLocationMenuModel*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSearchLocation*(self: AccessInterface, location: string, subLocation: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSearchLocationObject*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method searchMessages*(self: AccessInterface, searchTerm: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method resultItemClicked*(self: AccessInterface, itemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")
