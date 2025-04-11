import io_interface
import app_service/service/market/service as market_service
import app_service/service/market/service_items
import app/core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    marketService: market_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  marketService: market_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.marketService = marketService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_MARKET_LEADERBOARD_PAGE_LOADED) do(e:Args):
    self.delegate.refreshData()

proc requestMarketTokenPage*(self: Controller, page: int, pageSize: int = 100, sortOrder: int = 0) =
  self.marketService.fetchMarketTokenPage(page, pageSize, sortOrder)

proc getMarketLeaderboardList*(self: Controller): var seq[MarketItem] =
  return self.marketService.getMarketLeaderboardList()

proc getMarketLeaderboardLoading*(self: Controller): bool =
  return self.marketService.getMarketLeaderboardLoading()

proc getTotalMarketLeaderboardModelCount*(self: Controller): int =
  return self.marketService.getTotalMarketLeaderboardModelCount()

proc getCurrentPage*(self: Controller): int =
  return self.marketService.getCurrentPage()
