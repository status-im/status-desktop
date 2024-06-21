import app/modules/shared_modules/collectibles_search/controller as collectibles_search_c
import app/modules/shared_modules/collections_search/controller as collections_search_c


type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectiblesSearchController*(self: AccessInterface): collectibles_search_c.Controller {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectionsSearchController*(self: AccessInterface): collections_search_c.Controller {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
