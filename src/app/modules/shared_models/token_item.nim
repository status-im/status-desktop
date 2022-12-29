import strformat

import ../../../app_service/service/wallet_account/dto
import ./balance_item as balance_item
import ./balance_model as balance_model
import ./currency_amount

type
  Item* = object
    name: string
    symbol: string
    totalBalance: CurrencyAmount
    totalCurrencyBalance: CurrencyAmount
    enabledNetworkCurrencyBalance: CurrencyAmount
    enabledNetworkBalance: CurrencyAmount
    visibleForNetwork: bool
    visibleForNetworkWithPositiveBalance: bool
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
    pegSymbol: string

proc initItem*(
  name, symbol: string,
  totalBalance: CurrencyAmount,
  totalCurrencyBalance: CurrencyAmount,
  enabledNetworkBalance: CurrencyAmount,
  enabledNetworkCurrencyBalance: CurrencyAmount,
  visibleForNetwork: bool,
  visibleForNetworkWithPositiveBalance: bool,
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
  pegSymbol: string,
): Item =
  result.name = name
  result.symbol = symbol
  result.totalBalance = totalBalance
  result.totalCurrencyBalance = totalCurrencyBalance
  result.enabledNetworkBalance = enabledNetworkBalance
  result.enabledNetworkCurrencyBalance = enabledNetworkCurrencyBalance
  result.visibleForNetwork = visibleForNetwork
  result.visibleForNetworkWithPositiveBalance = visibleForNetworkWithPositiveBalance
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
  result.pegSymbol = pegSymbol

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    symbol: {self.symbol},
    totalBalance: {self.totalBalance},
    totalCurrencyBalance: {self.totalCurrencyBalance},
    enabledNetworkBalance: {self.enabledNetworkBalance},
    enabledNetworkCurrencyBalance: {self.enabledNetworkCurrencyBalance},
    visibleForNetworkWithPositiveBalance: {self.visibleForNetworkWithPositiveBalance},
    visibleForNetwork: {self.visibleForNetwork},
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
    pegSymbol: {self.pegSymbol},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getSymbol*(self: Item): string =
  return self.symbol

proc getTotalBalance*(self: Item): CurrencyAmount =
  return self.totalBalance

proc getTotalCurrencyBalance*(self: Item): CurrencyAmount =
  return self.totalCurrencyBalance

proc getEnabledNetworkBalance*(self: Item): CurrencyAmount =
  return self.enabledNetworkBalance

proc getEnabledNetworkCurrencyBalance*(self: Item): CurrencyAmount =
  return self.enabledNetworkCurrencyBalance

proc getVisibleForNetwork*(self: Item): bool =
  return self.visibleForNetwork

proc getVisibleForNetworkWithPositiveBalance*(self: Item): bool =
  return self.visibleForNetworkWithPositiveBalance

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

proc getPegSymbol*(self: Item): string =
  return self.pegSymbol
