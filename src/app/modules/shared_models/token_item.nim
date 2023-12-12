import strformat

import ./balance_item as balance_item
import ./balance_model as balance_model
import ./currency_amount

type
  Item* = object
    name: string
    symbol: string
    totalRawBalance: string
    totalBalance: CurrencyAmount
    totalCurrencyBalance: CurrencyAmount
    enabledNetworkCurrencyBalance: CurrencyAmount
    enabledNetworkBalance: CurrencyAmount
    balances: balance_model.BalanceModel
    description: string
    assetWebsiteUrl: string
    builtOn: string
    address: string
    marketCap: CurrencyAmount
    highDay: CurrencyAmount
    lowDay: CurrencyAmount
    changePctHour: float64
    changePctDay: float64
    changePct24hour: float64
    change24hour: float64
    currencyPrice: CurrencyAmount
    decimals: int
    image: string
    communityId: string
    communityName: string
    communityImage: string
    loading: bool

proc initItem*(
  name, symbol, totalRawBalance: string,
  totalBalance: CurrencyAmount,
  totalCurrencyBalance: CurrencyAmount,
  enabledNetworkBalance: CurrencyAmount,
  enabledNetworkCurrencyBalance: CurrencyAmount,
  balances: seq[balance_item.Item],
  description: string,
  assetWebsiteUrl: string,
  builtOn: string,
  address: string,
  marketCap: CurrencyAmount,
  highDay: CurrencyAmount,
  lowDay: CurrencyAmount,
  changePctHour: float64,
  changePctDay: float64,
  changePct24hour: float64,
  change24hour: float64,
  currencyPrice: CurrencyAmount,
  decimals: int,
  image: string,
  communityId: string,
  communityName: string,
  communityImage: string,
  loading: bool = false
): Item =
  result.name = name
  result.symbol = symbol
  result.totalRawBalance = totalRawBalance
  result.totalBalance = totalBalance
  result.totalCurrencyBalance = totalCurrencyBalance
  result.enabledNetworkBalance = enabledNetworkBalance
  result.enabledNetworkCurrencyBalance = enabledNetworkCurrencyBalance
  result.balances = balance_model.newModel()
  result.balances.setItems(balances)
  result.description =  description
  result.assetWebsiteUrl = assetWebsiteUrl
  result.builtOn = builtOn
  result.address = address
  result.marketCap = marketCap
  result.highDay = highDay
  result.lowDay = lowDay
  result.changePctHour = changePctHour
  result.changePctDay = changePctDay
  result.changePct24hour = changePct24hour
  result.change24hour = change24hour
  result.currencyPrice = currencyPrice
  result.decimals = decimals
  result.image = image
  result.communityId = communityId
  result.communityName = communityName
  result.communityImage = communityImage
  result.loading = loading

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    symbol: {self.symbol},
    totalRawBalance: {self.totalRawBalance},
    totalBalance: {self.totalBalance},
    totalCurrencyBalance: {self.totalCurrencyBalance},
    enabledNetworkBalance: {self.enabledNetworkBalance},
    enabledNetworkCurrencyBalance: {self.enabledNetworkCurrencyBalance},
    description: {self.description},
    assetWebsiteUrl: {self.assetWebsiteUrl}
    builtOn: {self.builtOn}
    address: {self.address}
    marketCap: {self.marketCap},
    highDay: {self.highDay},
    lowDay: {self.lowDay},
    changePctHour: {self.changePctHour},
    changePctDay: {self.changePctDay},
    changePct24hour: {self.changePct24hour},
    change24hour: {self.change24hour},
    currencyPrice: {self.currencyPrice},
    decimals: {self.decimals},
    image: {self.image},
    communityId: {self.communityId},
    communityName: {self.communityName},
    communityImage: {self.communityImage},
    loading: {self.loading},
    ]"""

proc initLoadingItem*(): Item =
  return initItem(
    name = "",
    symbol = "",
    totalRawBalance = "0",
    totalBalance = newCurrencyAmount(),
    totalCurrencyBalance = newCurrencyAmount(),
    enabledNetworkBalance = newCurrencyAmount(),
    enabledNetworkCurrencyBalance = newCurrencyAmount(),
    balances = @[],
    description = "",
    assetWebsiteUrl = "",
    builtOn = "",
    address = "",
    marketCap = newCurrencyAmount(),
    highDay = newCurrencyAmount(),
    lowDay = newCurrencyAmount(),
    changePctHour = 0,
    changePctDay = 0,
    changePct24hour = 0,
    change24hour = 0,
    currencyPrice = newCurrencyAmount(),
    decimals = 0,
    image = "",
    communityId = "",
    communityName = "",
    communityImage = "",
    loading = true
  )

proc getName*(self: Item): string =
  return self.name

proc getSymbol*(self: Item): string =
  return self.symbol

proc getTotalRawBalance*(self: Item): string =
  return self.totalRawBalance

proc getTotalBalance*(self: Item): CurrencyAmount =
  return self.totalBalance

proc getTotalCurrencyBalance*(self: Item): CurrencyAmount =
  return self.totalCurrencyBalance

proc getEnabledNetworkBalance*(self: Item): CurrencyAmount =
  return self.enabledNetworkBalance

proc getEnabledNetworkCurrencyBalance*(self: Item): CurrencyAmount =
  return self.enabledNetworkCurrencyBalance

proc getBalances*(self: Item): balance_model.BalanceModel =
  return self.balances

proc getDescription*(self: Item): string =
  return self.description

proc getAssetWebsiteUrl*(self: Item): string =
  return self.assetWebsiteUrl

proc getBuiltOn*(self: Item): string =
  return self.builtOn

proc getAddress*(self: Item): string =
  return self.address

proc getMarketCap*(self: Item): CurrencyAmount =
  return self.marketCap

proc getHighDay*(self: Item): CurrencyAmount =
  return self.highDay

proc getLowDay*(self: Item): CurrencyAmount =
  return self.lowDay

proc getChangePctHour*(self: Item): float64 =
  return self.changePctHour

proc getChangePctDay*(self: Item): float64 =
  return self.changePctDay

proc getChangePct24hour*(self: Item): float64 =
  return self.changePct24hour

proc getChange24hour*(self: Item): float64 =
  return self.change24hour

proc getCurrencyPrice*(self: Item): CurrencyAmount =
  return self.currencyPrice

proc getDecimals*(self: Item): int =
  return self.decimals

proc getImage*(self: Item): string =
  return self.image

proc getCommunityId*(self: Item): string =
  return self.communityId

proc getCommunityName*(self: Item): string =
  return self.communityName

proc getCommunityImage*(self: Item): string =
  return self.communityImage

proc getLoading*(self: Item): bool =
  return self.loading
