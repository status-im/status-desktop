import NimQml, Tables, strutils, strformat

import ../../../app_service/service/wallet_account/dto

type
  ModelRole {.pure.} = enum
    ChainId = UserRole + 1,
    Address
    Balance

QtObject:
  type
    BalanceModel* = ref object of QAbstractListModel
      items*: seq[BalanceDto]

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
      result = newQVariant($item.balance)

  proc rowData(self: BalanceModel, index: int, column: string): string {.slot.} =
    if (index >= self.items.len):
      return
    let item = self.items[index]
    case column:
      of "chainId": result = $item.chainId
      of "address": result = $item.address
      of "balance": result = $item.balance

  proc setItems*(self: BalanceModel, items: seq[BalanceDto]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
