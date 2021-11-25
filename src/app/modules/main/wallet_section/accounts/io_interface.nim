type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method generateNewAccount*(self: AccessInterface, password: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromPrivateKey*(self: AccessInterface, privateKey: string, password: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addAccountsFromSeed*(self: AccessInterface, seedPhrase: string, password: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addWatchOnlyAccount*(self: AccessInterface, address: string, accountName: string, color: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteAccount*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshWalletAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi 
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
  