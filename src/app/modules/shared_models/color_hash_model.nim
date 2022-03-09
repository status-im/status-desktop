import NimQml, Tables

import color_hash_item

type
  ModelRole {.pure.} = enum
    Length = UserRole + 1
    ColorIdx

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items*: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.Length:
        result = newQVariant(item.length)
      of ModelRole.ColorIdx:
        result = newQVariant(item.colorIdx)

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Length.int:"length",
      ModelRole.ColorIdx.int:"colorIdx",
    }.toTable
