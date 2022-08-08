import strformat

import ../../../app_service/service/wallet_account/dto
import ./balance_model as balance_model

type
  Item* = object
    name: string
    symbol: string
    totalBalance: float
    totalCurrencyBalance: float
    enabledNetworkCurrencyBalance: float
    enabledNetworkBalance: float
    networkVisible: bool
    balances: balance_model.BalanceModel
    description: string
    assetWebsiteUrl: string
    builtOn: string
    smartContractAddress: string
    marketCap: string
    highDay: string
    lowDay: string
    changePctHour: string
    changePctDay: string
    changePct24hour: string

proc initItem*(
  name, symbol: string,
  totalBalance: float,
  totalCurrencyBalance: float,
  enabledNetworkBalance: float,
  enabledNetworkCurrencyBalance: float,
  networkVisible: bool,
  balances: seq[BalanceDto],
  description: string,
  assetWebsiteUrl: string,
  builtOn: string,
  smartContractAddress: string,
  marketCap: string,
  highDay: string,
  lowDay: string,
  changePctHour: string,
  changePctDay: string,
  changePct24hour: string,
): Item =
  result.name = name
  result.symbol = symbol
  result.totalBalance = totalBalance
  result.totalCurrencyBalance = totalCurrencyBalance
  result.enabledNetworkBalance = enabledNetworkBalance
  result.enabledNetworkCurrencyBalance = enabledNetworkCurrencyBalance
  result.networkVisible = networkVisible
  result.balances = balance_model.newModel()
  result.balances.setItems(balances)
  result.description =  description
  result.assetWebsiteUrl = assetWebsiteUrl
  result.builtOn = builtOn
  result.smartContractAddress = smartContractAddress
  result.marketCap = marketCap
  result.highDay = highDay
  result.lowDay = lowDay
  result.changePctHour = changePctHour
  result.changePctDay = changePctDay
  result.changePct24hour = changePct24hour

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    symbol: {self.symbol},
    totalBalance: {self.totalBalance},
    totalCurrencyBalance: {self.totalCurrencyBalance},
    enabledNetworkBalance: {self.enabledNetworkBalance},
    enabledNetworkCurrencyBalance: {self.enabledNetworkCurrencyBalance},
    networkVisible: {self.networkVisible},
    description: {self.description},
    assetWebsiteUrl: {self.assetWebsiteUrl}
    builtOn: {self.builtOn}
    smartContractAddress: {self.smartContractAddress}
    marketCap: {self.marketCap},
    highDay: {self.highDay},
    lowDay: {self.lowDay},
    changePctHour: {self.changePctHour},
    changePctDay: {self.changePctDay},
    changePct24hour: {self.changePct24hour},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getSymbol*(self: Item): string =
  return self.symbol

proc getTotalBalance*(self: Item): float =
  return self.totalBalance

proc getTotalCurrencyBalance*(self: Item): float =
  return self.totalCurrencyBalance

proc getEnabledNetworkBalance*(self: Item): float =
  return self.enabledNetworkBalance

proc getEnabledNetworkCurrencyBalance*(self: Item): float =
  return self.enabledNetworkCurrencyBalance

proc getNetworkVisible*(self: Item): bool =
  return self.networkVisible

proc getBalances*(self: Item): balance_model.BalanceModel =
  return self.balances

proc getDescription*(self: Item): string =
  return self.description

proc getAssetWebsiteUrl*(self: Item): string =
  return self.assetWebsiteUrl

proc getBuiltOn*(self: Item): string =
  return self.builtOn

proc getSmartContractAddress*(self: Item): string =
  return self.smartContractAddress

proc getMarketCap*(self: Item): string =
  return self.marketCap

proc getHighDay*(self: Item): string =
  return self.highDay

proc getLowDay*(self: Item): string =
  return self.lowDay

proc getChangePctHour*(self: Item): string =
  return self.changePctHour

proc getChangePctDay*(self: Item): string =
  return self.changePctDay

proc getChangePct24hour*(self: Item): string =
  return self.changePct24hour
