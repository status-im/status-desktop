import NimQml
import ../../shared_models/currency_amount
export CurrencyAmount

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setFilterAddress*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setFillterAllAddresses*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleWatchOnlyAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateCurrency*(self: AccessInterface, currency: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentCurrency*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setTotalCurrencyBalance*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrencyAmount*(self: AccessInterface, amount: float64, symbol: string): CurrencyAmount {.base.} =
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

method assetsModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionsModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method networksModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method savedAddressesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method buySellCryptoModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method overviewModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runAddAccountPopup*(self: AccessInterface, addingWatchOnlyAccount: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method runEditAccountPopup*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAddAccountModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onAddAccountModuleLoaded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method destroyAddAccountPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworkLayer*(self: AccessInterface, chainId: int): string {.base.} =
  raise newException(ValueError, "No implementation available")