import NimQml, Tables

type
  RoleNames {.pure.} = enum
    Emoji = UserRole + 1,

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items*: seq[string]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc setItems*(self: Model, items: seq[string]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc items*(self: Model): seq[string] =
    return self.items

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    return newQVariant(self.items[index.row])

  method roleNames(self: Model): Table[int, string] =
    { RoleNames.Emoji.int:"emoji" }.toTable
