import NimQml, Tables
import token_permission_chat_list_item

type
  ModelRole {.pure.} = enum
    Key = UserRole + 1

QtObject:
  type TokenPermissionChatListModel* = ref object of QAbstractListModel
    items*: seq[TokenPermissionChatListItem]

  proc setup(self: TokenPermissionChatListModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenPermissionChatListModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenPermissionChatListModel*(): TokenPermissionChatListModel =
    new(result, delete)
    result.setup

  method roleNames(self: TokenPermissionChatListModel): Table[int, string] =
    {
      ModelRole.Key.int:"key",
    }.toTable

  proc countChanged(self: TokenPermissionChatListModel) {.signal.}
  proc getCount(self: TokenPermissionChatListModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TokenPermissionChatListModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: TokenPermissionChatListModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Key:
        result = newQVariant(item.getKey())

  proc addItem*(self: TokenPermissionChatListModel, item: TokenPermissionChatListItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc setItems*(self: TokenPermissionChatListModel, items: seq[TokenPermissionChatListItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getItems*(self: TokenPermissionChatListModel): seq[TokenPermissionChatListItem] =
    return self.items
