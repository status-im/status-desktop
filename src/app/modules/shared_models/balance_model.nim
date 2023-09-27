import NimQml, Tables, strutils, stint, strformat, algorithm

import balance_item
import ./currency_amount

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1,
    Address
    Balance
    RawBalance

QtObject:
  type
    BalanceModel* = ref object of QAbstractListModel
      items*: seq[Item]

  proc delete(self: BalanceModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: BalanceModel) =
    self.QAbstractListModel.setup

  proc newModel*(): BalanceModel =
    new(result, delete)
    result.setup

  proc `$`*(self: BalanceModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: BalanceModel) {.signal.}

  proc getCount*(self: BalanceModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: BalanceModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: BalanceModel): Table[int, string] =
    {
      ModelRole.ChainId.int:"chainId",
      ModelRole.Address.int:"address",
      ModelRole.Balance.int:"balance",
      ModelRole.RawBalance.int:"rawBalance",
    }.toTable

  method data(self: BalanceModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ChainId:
      result = newQVariant(item.chainId)
    of ModelRole.Address:
      result = newQVariant(item.address)
    of ModelRole.Balance:
      result = newQVariant(item.balance)
    of ModelRole.RawBalance:
      result = newQVariant(item.rawBalance.toString(10))

  proc rowData(self: BalanceModel, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "chainId": result = $item.chainId
      of "address": result = $item.address
      of "balance": result = $item.balance
      of "rawBalance": result = $item.rawBalance.toString(10)


  proc cmpBalances*(x, y: Item): int =
    cmp(x.balance.getAmount(), y.balance.getAmount())

  proc setItems*(self: BalanceModel, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.items.sort(cmpBalances, SortOrder.Descending)
    self.endResetModel()
    self.countChanged()
