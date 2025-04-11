import json

type
  WalletConfig* = object
    tokensListsAutoRefreshInterval*: int
    tokensListsAutoRefreshCheckInterval*: int
    marketDataFullDataRefreshInterval*: int
    marketDataPriceRefreshInterval*: int

proc toJson*(self: WalletConfig): JsonNode =
  return %* {
    "tokensListsAutoRefreshInterval": self.tokensListsAutoRefreshInterval,
    "tokensListsAutoRefreshCheckInterval": self.tokensListsAutoRefreshCheckInterval,
    "marketDataFullDataRefreshInterval": self.marketDataFullDataRefreshInterval,
    "marketDataPriceRefreshInterval": self.marketDataPriceRefreshInterval,
  }
