import ./dto

export dto

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAccountByAddress*(self: ServiceInterface, address: string): WalletAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccounts*(self: ServiceInterface): seq[WalletAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccount*(self: ServiceInterface, accountIndex: int): WalletAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrencyBalance*(self: ServiceInterface): float64 {.base.} =
  raise newException(ValueError, "No implementation available")

method generateNewAccount*(self: ServiceInterface, password: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromPrivateKey*(self: ServiceInterface, privateKey: string, password: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromSeed*(self: ServiceInterface, seedPhrase: string, password: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addWatchOnlyAccount*(self: ServiceInterface, address: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteAccount*(self: ServiceInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateCurrency*(self: ServiceInterface, newCurrency: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateWalletAccount*(self: ServiceInterface, address: string, accountName: string, color: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleTokenVisible*(self: ServiceInterface, symbol: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPrice*(self: ServiceInterface, crypto: string, fiat: string): float64 {.base.} =
  raise newException(ValueError, "No implementation available")
