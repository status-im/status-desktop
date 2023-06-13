import NimQml, Tables
import token_permission_item
import token_criteria_model

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Key
    Type
    TokenCriteria
    ChatList
    IsPrivate

QtObject:
  type TokenPermissionsModel* = ref object of QAbstractListModel
    items*: seq[TokenPermissionItem]

  proc setup(self: TokenPermissionsModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenPermissionsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenPermissionsModel*(): TokenPermissionsModel =
    new(result, delete)
    result.setup

  method roleNames(self: TokenPermissionsModel): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.Key.int:"key",
      ModelRole.Type.int:"permissionType",
      ModelRole.TokenCriteria.int:"holdingsListModel",
      ModelRole.ChatList.int:"channelsModel",
      ModelRole.IsPrivate.int:"isPrivate",
    }.toTable

  proc countChanged(self: TokenPermissionsModel) {.signal.}
  proc getCount*(self: TokenPermissionsModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TokenPermissionsModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: TokenPermissionsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Id:
        result = newQVariant(item.getId())
      of ModelRole.Key:
        result = newQVariant(item.getId())
      of ModelRole.Type:
        result = newQVariant(item.getType())
      of ModelRole.TokenCriteria:
        result = newQVariant(item.getTokenCriteria())
      of ModelRole.ChatList:
        result = newQVariant(item.getChatList())
      of ModelRole.IsPrivate:
        result = newQVariant(item.getIsPrivate())

  proc addItem*(self: TokenPermissionsModel, item: TokenPermissionItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc setItems*(self: TokenPermissionsModel, items: seq[TokenPermissionItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getItems*(self: TokenPermissionsModel): seq[TokenPermissionItem] =
    return self.items

  proc findIndexById(self: TokenPermissionsModel, id: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].getId() == id):
        return i
    return -1

  proc removeItemWithId*(self: TokenPermissionsModel, permissionId: string) =
    let idx = self.findIndexById(permissionId)
    if(idx == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, idx, idx)
    self.items.delete(idx)
    self.endRemoveRows()
    self.countChanged()

  proc getItemById*(self: TokenPermissionsModel, permissionId: string): TokenPermissionItem =
    let idx = self.findIndexById(permissionId)
    if(idx == -1):
      return

    return self.items[idx]

  proc updateItem*(self: TokenPermissionsModel, permissionId: string, item: TokenPermissionItem) =
    let idx = self.findIndexById(permissionId)
    if(idx == -1):
      return

    self.items[idx].`type` = item.`type`
    self.items[idx].tokenCriteria.setItems(item.tokenCriteria.getItems())
    self.items[idx].isPrivate = item.isPrivate
    self.items[idx].tokenCriteriaMet = item.tokenCriteriaMet

    let index = self.createIndex(idx, 0, nil)
    self.dataChanged(index, index, @[
      ModelRole.Id.int,
      ModelRole.Key.int,
      ModelRole.Type.int,
      ModelRole.TokenCriteria.int,
      ModelRole.IsPrivate.int
    ])

