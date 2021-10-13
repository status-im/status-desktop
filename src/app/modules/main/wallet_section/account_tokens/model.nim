import NimQml, Tables, strutils, strformat

import ./item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Symbol
    Value
    Address
    FiatBalanceDisplay
    FiatBalance

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

  proc getCount(self: Model): int {.slot.} =
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
      ModelRole.Value.int:"value",
      ModelRole.Address.int:"address",
      ModelRole.FiatBalanceDisplay.int:"fiatBalanceDisplay",
      ModelRole.FiatBalance.int:"fiatBalance"
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
    of ModelRole.Value: 
      result = newQVariant(item.getValue())
    of ModelRole.Address: 
      result = newQVariant(item.getAddress())
    of ModelRole.FiatBalanceDisplay: 
      result = newQVariant(item.getFiatBalanceDisplay())
    of ModelRole.FiatBalance: 
      result = newQVariant(item.getFiatBalance())

  proc setData*(self: Model, item: seq[Item]) =
    self.countChanged()