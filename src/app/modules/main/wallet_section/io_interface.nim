type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method switchAccount*(self: AccessInterface, accountIndex: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchAccountByAddress*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateCurrency*(self: AccessInterface, currency: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setTotalCurrencyBalance*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# Methods called by submodules of this module
method accountsModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method allTokensModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method collectiblesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method currentAccountModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionsModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method savedAddressesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method buySellCryptoModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
