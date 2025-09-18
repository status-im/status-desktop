import nimqml, tables, strutils, stew/shims/strformat, sequtils

import backend/backend

type
  ModelRole {.pure.} = enum
    ChainIdRole = UserRole + 1
    TransactionHashRole
    AddressRole

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[backend.TransactionIdentity]

  proc delete(self: Model)
  proc setup(self: Model)
  proc newModel*(): Model =
    new(result, delete)
    result.items = @[]
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
      ModelRole.ChainIdRole.int:"chainId",
      ModelRole.TransactionHashRole.int:"txHash",
      ModelRole.AddressRole.int:"address"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ChainIdRole:
      result = newQVariant(item.chainId)
    of ModelRole.TransactionHashRole:
      result = newQVariant(item.hash)
    of ModelRole.AddressRole:
      result = newQVariant(item.address)
  
  proc setItems*(self: Model, items: seq[backend.TransactionIdentity]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc delete(self: Model) =
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

