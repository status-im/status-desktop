import app_service/service/market/service as market_service

type
  MarketLeaderboardDataSource* = tuple[
    getMarketLeaderboardList: proc(): var seq[MarketItem]
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

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMarketLeaderboardLoading*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getTotalMarketLeaderboardModelCount*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentPage*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getMarketLeaderboardDataSource*(self: AccessInterface): MarketLeaderboardDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method loadPage*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method updatePage*(self: AccessInterface, updates: seq[LeaderboardTokenUpdated]) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestMarketTokenPage*(self: AccessInterface, page: int, pageSize: int = 100, sortOrder: int = 0) {.base.} =
  raise newException(ValueError, "No implementation available")

method unsubscribeFromUpdates*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
