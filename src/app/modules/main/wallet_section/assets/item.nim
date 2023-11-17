import strformat

type
  Item* = object
    assetsLoading: bool
    hasBalanceCache: bool
    hasMarketValuesCache: bool

proc initItem*(
  assetsLoading: bool  = true,
  hasBalanceCache: bool = false,
  hasMarketValuesCache: bool = false
): Item =
  result.assetsLoading = assetsLoading
  result.hasBalanceCache = hasBalanceCache
  result.hasMarketValuesCache = hasMarketValuesCache

proc `$`*(self: Item): string =
  result = fmt"""WalletAssetItem(
    assetsLoading: {self.assetsLoading},
    hasBalanceCache: {self.hasBalanceCache},
    hasMarketValuesCache: {self.hasMarketValuesCache},
    ]"""

proc getAssetsLoading*(self: Item): bool =
  return self.assetsLoading

proc getHasBalanceCache*(self: Item): bool =
  return self.hasBalanceCache

proc getHasMarketValuesCache*(self: Item): bool =
  return self.hasMarketValuesCache
