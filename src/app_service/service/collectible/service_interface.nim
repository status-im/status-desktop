import dto

export dto

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollections*(self: ServiceInterface, address: string): seq[CollectionDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectibles*(self: ServiceInterface, address: string, collectionSlug: string): seq[CollectibleDto] {.base.} =
  raise newException(ValueError, "No implementation available")
