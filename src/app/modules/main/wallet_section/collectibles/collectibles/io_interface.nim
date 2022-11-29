import ../../../../../../app_service/service/collectible/service as collectible_service
import ./item

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setCurrentAddress*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetch*(self: AccessInterface, collectionSlug: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setCollectibles*(self: AccessInterface, collectionSlug: string, collectibles: seq[CollectibleDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectible*(self: AccessInterface, collectionSlug: string, id: int) : Item {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
