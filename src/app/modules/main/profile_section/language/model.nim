import NimQml, tables

import item

type
  ModelRole {.pure.} = enum
    Locale = UserRole + 1
    Name
    Native
    Flag

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

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Locale.int: "locale",
      ModelRole.Name.int: "name",
      ModelRole.Native.int: "native",
      ModelRole.Flag.int: "flag",
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Locale:
      result = newQVariant(item.locale)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.Native:
      result = newQVariant(item.native)
    of ModelRole.Flag:
      result = newQVariant(item.flag)
