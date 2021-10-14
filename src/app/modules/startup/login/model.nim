import NimQml, Tables, strutils, strformat

import account_item

type
  ModelRole {.pure.} = enum
    Account = UserRole + 1

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[AccountItem]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc countChanged*(self: Model) {.signal.}

  proc count*(self: Model): int {.slot.}  =
    self.items.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Account.int:"account"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Account: 
      result = newQVariant(item)

  proc setItems*(self: Model, items: seq[AccountItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()