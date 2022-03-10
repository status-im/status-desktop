import ../../../../../app_service/service/wallet_account/service as wallet_account_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccounts*(self: AccessInterface): seq[wallet_account_service.WalletAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method generateNewAccount*(self: AccessInterface, password: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromPrivateKey*(self: AccessInterface, privateKey: string, password: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromSeed*(self: AccessInterface, seedPhrase: string, password: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addWatchOnlyAccount*(self: AccessInterface, address: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteAccount*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")


type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
