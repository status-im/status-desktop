import NimQml
import Tables

type
  RoleNames {.pure.} = enum
    Name = UserRole + 1,

QtObject:
  type
    ChatsModel* = ref object of QAbstractListModel
      names*: seq[string]

  proc delete(self: ChatsModel) =
    self.QAbstractListModel.delete

  proc setup(self: ChatsModel) =
    self.QAbstractListModel.setup

  proc newChatsModel*(): ChatsModel =
    new(result, delete)
    result.names = @["test", "test2"]
    result.setup

  proc addNameTolist*(self: ChatsModel, name: string) =
      self.names.add(name)

  method rowCount(self: ChatsModel, index: QModelIndex = nil): int =
    return self.names.len

  method data(self: ChatsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.names.len:
      return
    return newQVariant(self.names[index.row])

  method roleNames(self: ChatsModel): Table[int, string] =
    { RoleNames.Name.int:"name"}.toTable
