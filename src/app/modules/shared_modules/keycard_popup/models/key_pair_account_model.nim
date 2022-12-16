import NimQml, Tables, strformat
import key_pair_account_item

export key_pair_account_item

type
  ModelRole {.pure.} = enum
    Account = UserRole + 1

QtObject:
  type
    KeyPairAccountModel* = ref object of QAbstractListModel
      items: seq[KeyPairAccountItem]

  proc delete(self: KeyPairAccountModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: KeyPairAccountModel) =
    self.QAbstractListModel.setup

  proc newKeyPairAccountModel*(): KeyPairAccountModel =
    new(result, delete)
    result.setup

  proc countChanged(self: KeyPairAccountModel) {.signal.}
  proc getCount*(self: KeyPairAccountModel): int {.slot.} =
    self.items.len
  QtProperty[int]count:
    read = getCount
    notify = countChanged

  proc `$`*(self: KeyPairAccountModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""KeyPairAccountModel:
      [{i}]:({$self.items[i]})
      """

  method rowCount(self: KeyPairAccountModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: KeyPairAccountModel): Table[int, string] =
    {
      ModelRole.Account.int: "account"
    }.toTable

  method data(self: KeyPairAccountModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return
    if (index.row < 0 or index.row >= self.items.len):
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
    of ModelRole.Account:
      result = newQVariant(item)

  proc getItems*(self: KeyPairAccountModel): seq[KeyPairAccountItem] =
    return self.items

  proc setItems*(self: KeyPairAccountModel, items: seq[KeyPairAccountItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc addItem*(self: KeyPairAccountModel, item: KeyPairAccountItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc getItemAtIndex*(self: KeyPairAccountModel, index: int): KeyPairAccountItem =
    if index < 0 or index >= self.items.len:
      return newKeyPairAccountItem()
    return self.items[index]

  proc removeItemAtIndex*(self: KeyPairAccountModel, index: int) =
    if (index < 0 or index >= self.items.len):
      return
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()