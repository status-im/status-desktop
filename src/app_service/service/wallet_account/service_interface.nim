import ./dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccounts*(self: ServiceInterface): seq[WalletAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccount*(self: ServiceInterface, accountIndex: int): WalletAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")
