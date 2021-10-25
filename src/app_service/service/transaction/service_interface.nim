import dto, stint

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRecentHistory*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTransfersByAddress*(self: ServiceInterface, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): seq[TransactionDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getTransfersByAddressTemp*(self: ServiceInterface, address: string, toBlock: Uint256, limit: int, loadMore: bool = false): string {.base.} =
  raise newException(ValueError, "No implementation available")