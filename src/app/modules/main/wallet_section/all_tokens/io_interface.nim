import app_service/service/token/service_items

type
  SourcesOfTokensModelDataSource* = tuple[
    getSourcesOfTokensList: proc(): var seq[SupportedSourcesItem]
  ]
type
  FlatTokenModelDataSource* = tuple[
    getFlatTokensList: proc(): var seq[TokenItem]
  ]
type
  TokenBySymbolModelDataSource* = tuple[
    getTokenBySymbolList: proc(): var seq[TokenBySymbolItem]
  ]
type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method findTokenSymbolByAddress*(self: AccessInterface, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getHistoricalDataForToken*(self: AccessInterface, symbol: string, currency: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method tokenHistoricalDataResolved*(self: AccessInterface, tokenDetails: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchHistoricalBalanceForTokenAsJson*(self: AccessInterface, address: string, allAddresses: bool, tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method tokenBalanceHistoryDataResolved*(self: AccessInterface, balanceHistoryJson: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSourcesOfTokensModelDataSource*(self: AccessInterface): SourcesOfTokensModelDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method getFlatTokenModelDataSource*(self: AccessInterface): FlatTokenModelDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenBySymbolModelDataSource*(self: AccessInterface): TokenBySymbolModelDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method filterChanged*(self: AccessInterface, addresses: seq[string]) =
  raise newException(ValueError, "No implementation available")