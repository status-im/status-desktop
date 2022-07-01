import NimQml, Tables, strutils, strformat

import ./token_item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Symbol
    TotalBalance
    TotalCurrencyBalance
    EnabledNetworkCurrencyBalance
    EnabledNetworkBalance
    NetworkVisible
    Balances

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
      ModelRole.NetworkVisible.int:"networkVisible",
      ModelRole.Balances.int:"balances",
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
    of ModelRole.NetworkVisible:
      result = newQVariant(item.getNetworkVisible())
    of ModelRole.Balances:
      result = newQVariant(item.getBalances())

  proc rowData(self: Model, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "name": result = $item.getName()
      of "symbol": result = $item.getSymbol()
      of "totalBalance": result = $item.getTotalBalance()
      of "totalCurrencyBalance": result = $item.getTotalCurrencyBalance()
      of "enabledNetworkCurrencyBalance": result = $item.getEnabledNetworkCurrencyBalance()
      of "enabledNetworkBalance": result = $item.getEnabledNetworkBalance()
      of "networkVisible": result = $item.getNetworkVisible()

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

  proc hasGas*(self: Model, chainId: int, nativeGasSymbol: string, requiredGas: float): bool {.slot.} =
    for item in self.items:
        if(item.getSymbol() != nativeGasSymbol):
            continue

        for balance in item.getBalances().items:
            if (balance.chainId != chainId):
                continue

            if(balance.balance >= requiredGas):
                return true

    return false
