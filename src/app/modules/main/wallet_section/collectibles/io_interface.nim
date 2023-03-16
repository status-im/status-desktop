import ../../../../../app_service/service/collectible/service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method switchAccount*(self: AccessInterface, accountIndex: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchCollections*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setCollections*(self: AccessInterface, collections: CollectionsData) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchCollectibles*(self: AccessInterface, collectionSlug: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateCollection*(self: AccessInterface, collection: CollectionData) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# Methods called by submodules of this module
method collectiblesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method collectionsModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method currentCollectibleModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
