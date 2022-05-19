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

proc initItem*(
  name, symbol: string,
  totalBalance: float,
  totalCurrencyBalance: float,
  enabledNetworkBalance: float,
  enabledNetworkCurrencyBalance: float,
  networkVisible: bool,
  balances: seq[BalanceDto]
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

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    symbol: {self.symbol},
    totalBalance: {self.totalBalance},
    totalCurrencyBalance: {self.totalCurrencyBalance},
    enabledNetworkBalance: {self.enabledNetworkBalance},
    enabledNetworkCurrencyBalance: {self.enabledNetworkCurrencyBalance},
    networkVisible: {self.networkVisible},
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