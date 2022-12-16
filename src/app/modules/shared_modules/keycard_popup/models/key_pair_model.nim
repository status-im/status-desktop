import NimQml, Tables, strformat
import key_pair_item

export key_pair_item

type
  ModelRole {.pure.} = enum
    KeyPair = UserRole + 1

QtObject:
  type
    KeyPairModel* = ref object of QAbstractListModel
      items: seq[KeyPairItem]

  proc delete(self: KeyPairModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: KeyPairModel) =
    self.QAbstractListModel.setup

  proc newKeyPairModel*(): KeyPairModel =
    new(result, delete)
    result.setup

  proc countChanged(self: KeyPairModel) {.signal.}
  proc getCount*(self: KeyPairModel): int {.slot.} =
    self.items.len
  QtProperty[int]count:
    read = getCount
    notify = countChanged

  proc setItems*(self: KeyPairModel, items: seq[KeyPairItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc `$`*(self: KeyPairModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""KeyPairModel:
      [{i}]:({$self.items[i]})
      """

  method rowCount(self: KeyPairModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: KeyPairModel): Table[int, string] =
    {
      ModelRole.KeyPair.int: "keyPair",
    }.toTable

  method data(self: KeyPairModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return
    if (index.row < 0 or index.row >= self.items.len):
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
    of ModelRole.KeyPair:
      result = newQVariant(item)

  proc findItemByPublicKey*(self: KeyPairModel, publicKey: string): KeyPairItem =
    for i in 0 ..< self.items.len:
      if(self.items[i].getPubKey() == publicKey):
        return self.items[i]
    return nil