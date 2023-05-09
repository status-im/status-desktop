import stint
import ../../../../../../app_service/service/network/dto as network_dto
import ../../../../../../app_service/service/collectible/dto as collectible_dto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setCurrentNetwork*(self: AccessInterface, network: network_dto.NetworkDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method update*(self: AccessInterface, address: string, tokenId: Uint256) {.base.} =
  raise newException(ValueError, "No implementation available")

method setData*(self: AccessInterface, collection: collectible_dto.CollectionDto, collectible: collectible_dto.CollectibleDto, network: network_dto.NetworkDto) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
