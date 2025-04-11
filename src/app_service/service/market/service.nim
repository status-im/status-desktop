import NimQml, Tables, json, sequtils, chronicles, strutils, sugar

import app/core/eventemitter
import app/core/signals/types

import app_service/service/settings/service as settings_service

import ./service_items

import backend/backend as backend

export service_items

logScope:
  topics = "market-service"

# Signals which may be emitted by this service:
const SIGNAL_MARKET_LEADERBOARD_PAGE_LOADED* = "marketLeaderboardPageLoaded"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    settingsService: settings_service.Service
    marketLeaderboardTokens: seq[MarketItem]
    leaderboardPageLoading: bool
    totalLeaderboardCount: int
    currentPage: int

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    settingsService: settings_service.Service
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.settingsService = settingsService

  proc init*(self: Service) =
    self.events.on(SignalType.GetLeaderboardPageDone.event) do(e:Args):
      var data = WalletSignal(e)
      self.leaderboardPageLoading = false
      self.totalLeaderboardCount = data.leaderboardData.totalCount
      self.currentPage = data.leaderboardData.page
      self.marketLeaderboardTokens = data.leaderboardData.data.map(item =>
        MarketItem(
          key: item.id,
          name: item.name,
          symbol: item.symbol,
          image: item.image,
          currentPrice: item.currentPrice,
          marketCap: item.marketCap,
          totalVolume: item.totalVolume,
          priceChangePercentage24h: item.priceChangePercentage24h
      ))
      self.events.emit(SIGNAL_MARKET_LEADERBOARD_PAGE_LOADED, Args())

  proc fetchMarketTokenPage*(self: Service, page: int, pageSize: int = 100, sortOrder: int = 0) =
    self.leaderboardPageLoading =  true
    var currentCurrency = self.settingsService.getCurrency()
    discard backend.fetchMarketTokenPageAsync(page, pageSize, sortOrder, currentCurrency)

  proc getMarketLeaderboardList*(self: Service): var seq[MarketItem] =
    return self.marketLeaderboardTokens

  proc getMarketLeaderboardLoading*(self: Service): bool =
    return self.leaderboardPageLoading

  proc getTotalMarketLeaderboardModelCount*(self: Service): int =
    return self.totalLeaderboardCount

  proc getCurrentPage*(self: Service): int =
    return self.currentPage
