import ../../../../../app_service/service/wallet_account/service as wallet_account_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method generateNewAccount*(self: AccessInterface, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromPrivateKey*(self: AccessInterface, privateKey: string, password: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromSeed*(self: AccessInterface, seedPhrase: string, password: string, accountName: string, color: string, emoji: string, path: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addWatchOnlyAccount*(self: AccessInterface, address: string, accountName: string, color: string, emoji: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteAccount*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshWalletAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddressList*(self: AccessInterface, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddressListForMnemonic*(self: AccessInterface, mnemonic: string, path: string, pageSize: int, pageNumber: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDerivedAddressForPrivateKey*(self: AccessInterface, privateKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method validSeedPhrase*(self: AccessInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")