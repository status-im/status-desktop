import NimQml, Tables, strutils, strformat, json

import ./token_item
import ./currency_amount

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Symbol
    TotalBalance
    TotalCurrencyBalance
    EnabledNetworkCurrencyBalance
    EnabledNetworkBalance
    VisibleForNetwork
    VisibleForNetworkWithPositiveBalance
    Balances
    Description
    AssetWebsiteUrl
    BuiltOn
    Address
    MarketCap
    HighDay
    LowDay
    ChangePctHour
    ChangePctDay
    ChangePct24hour
    Change24hour
    CurrencyPrice
    Decimals
    Loading

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.Symbol.int:"symbol",
      ModelRole.TotalBalance.int:"totalBalance",
      ModelRole.TotalCurrencyBalance.int:"totalCurrencyBalance",
      ModelRole.EnabledNetworkCurrencyBalance.int:"enabledNetworkCurrencyBalance",
      ModelRole.EnabledNetworkBalance.int:"enabledNetworkBalance",
      ModelRole.VisibleForNetwork.int:"visibleForNetwork",
      ModelRole.VisibleForNetworkWithPositiveBalance.int:"visibleForNetworkWithPositiveBalance",
      ModelRole.Balances.int:"balances",
      ModelRole.Description.int:"description",
      ModelRole.AssetWebsiteUrl.int:"assetWebsiteUrl",
      ModelRole.BuiltOn.int:"builtOn",
      ModelRole.Address.int:"address",
      ModelRole.MarketCap.int:"marketCap",
      ModelRole.HighDay.int:"highDay",
      ModelRole.LowDay.int:"lowDay",
      ModelRole.ChangePctHour.int:"changePctHour",
      ModelRole.ChangePctDay.int:"changePctDay",
      ModelRole.ChangePct24hour.int:"changePct24hour",
      ModelRole.Change24hour.int:"change24hour",
      ModelRole.CurrencyPrice.int:"currencyPrice",
      ModelRole.Decimals.int:"decimals",
      ModelRole.Loading.int:"loading",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Name:
      result = newQVariant(item.getName())
    of ModelRole.Symbol:
      result = newQVariant(item.getSymbol())
    of ModelRole.TotalBalance:
      result = newQVariant(item.getTotalBalance())
    of ModelRole.TotalCurrencyBalance:
      result = newQVariant(item.getTotalCurrencyBalance())
    of ModelRole.EnabledNetworkCurrencyBalance:
      result = newQVariant(item.getEnabledNetworkCurrencyBalance())
    of ModelRole.EnabledNetworkBalance:
      result = newQVariant(item.getEnabledNetworkBalance())
    of ModelRole.VisibleForNetwork:
      result = newQVariant(item.getVisibleForNetwork())
    of ModelRole.VisibleForNetworkWithPositiveBalance:
      result = newQVariant(item.getVisibleForNetworkWithPositiveBalance())
    of ModelRole.Balances:
      result = newQVariant(item.getBalances())
    of ModelRole.Description:
      result = newQVariant(item.getDescription())
    of ModelRole.AssetWebsiteUrl:
      result = newQVariant(item.getAssetWebsiteUrl())
    of ModelRole.BuiltOn:
      result = newQVariant(item.getBuiltOn())
    of ModelRole.Address:
      result = newQVariant(item.getAddress())
    of ModelRole.MarketCap:
      result = newQVariant(item.getMarketCap())
    of ModelRole.HighDay:
      result = newQVariant(item.getHighDay())
    of ModelRole.LowDay:
      result = newQVariant(item.getLowDay())
    of ModelRole.ChangePctHour:
      result = newQVariant(item.getChangePctHour())
    of ModelRole.ChangePctDay:
      result = newQVariant(item.getChangePctDay())
    of ModelRole.ChangePct24hour:
      result = newQVariant(item.getChangePct24hour())
    of ModelRole.Change24hour:
      result = newQVariant(item.getChange24hour())
    of ModelRole.CurrencyPrice:
      result = newQVariant(item.getCurrencyPrice())
    of ModelRole.Decimals:
      result = newQVariant(item.getDecimals())
    of ModelRole.Loading:
      result = newQVariant(item.getLoading())

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "name": result = $item.getName()
      of "symbol": result = $item.getSymbol()
      of "totalBalance": result = $item.getTotalBalance().toJsonNode()
      of "totalCurrencyBalance": result = $item.getTotalCurrencyBalance().toJsonNode()
      of "enabledNetworkCurrencyBalance": result = $item.getEnabledNetworkCurrencyBalance()
      of "enabledNetworkBalance": result = $item.getEnabledNetworkBalance()
      of "visibleForNetwork": result = $item.getVisibleForNetwork()
      of "visibleForNetworkWithPositiveBalance": result = $item.getVisibleForNetworkWithPositiveBalance()
      of "description": result = $item.getDescription()
      of "assetWebsiteUrl": result = $item.getAssetWebsiteUrl()
      of "builtOn": result = $item.getBuiltOn()
      of "address": result = $item.getAddress()
      of "marketCap": result = $item.getMarketCap()
      of "highDay": result = $item.getHighDay()
      of "lowDay": result = $item.getLowDay()
      of "changePctHour": result = $item.getChangePctHour()
      of "changePctDay": result = $item.getChangePctDay()
      of "changePct24hour": result = $item.getChangePct24hour()
      of "change24hour": result = $item.getChange24hour()
      of "currencyPrice": result = $item.getCurrencyPrice()
      of "decimals": result = $item.getDecimals()
      of "loading": result = $item.getLoading()

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc hasChain*(self: Model, index: int, chainId: int): bool {.slot.} =
    let item = self.items[index]
    for balance in item.getBalances().items:
      if (balance.chainId == chainId):
        return true

    return false

  proc hasGas*(self: Model, chainId: int, nativeGasSymbol: string, requiredGas: float): bool =
    for item in self.items:
      if(item.getSymbol() != nativeGasSymbol):
        continue

      for balance in item.getBalances().items:
        if (balance.chainId != chainId):
          continue

        if(balance.balance.getAmount() >= requiredGas):
          return true

        break

      break

    return false
