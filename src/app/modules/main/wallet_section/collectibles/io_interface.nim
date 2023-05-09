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

method filterChanged*(self: AccessInterface, addresses: seq[string], chainIds: seq[int]) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchOwnedCollectibles*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onFetchStarted*(self: AccessInterface, chainId: int, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setCollectibles*(self: AccessInterface, data: seq[CollectiblesData]) {.base.} =
  raise newException(ValueError, "No implementation available")

method appendCollectibles*(self: AccessInterface, chainId: int, address: string, data: CollectiblesData) {.base.} =
  raise newException(ValueError, "No implementation available")

method resetCollectibles*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getHasCollectiblesCache*(self: AccessInterface): bool  {.base.} =
  raise newException(ValueError, "No implementation available")

# Methods called by submodules of this module
method collectiblesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method currentCollectibleModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
