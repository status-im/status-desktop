import NimQml, Tables, strformat
import key_pair_item

type
  ModelRole {.pure.} = enum
    PubKey = UserRole + 1
    Name
    Image
    Icon
    PairType
    Accounts
    DerivedFrom

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
      ModelRole.PubKey.int: "pubKey",
      ModelRole.Name.int: "name",
      ModelRole.Image.int: "image",
      ModelRole.Icon.int: "icon",
      ModelRole.PairType.int: "pairType",
      ModelRole.Accounts.int: "accounts",
      ModelRole.DerivedFrom.int: "derivedFrom"
    }.toTable

  method data(self: KeyPairModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return
    if (index.row < 0 or index.row >= self.items.len):
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
    of ModelRole.PubKey:
      result = newQVariant(item.pubKey)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.Image:
      result = newQVariant(item.image)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.PairType:
      result = newQVariant(item.pairType.int)
    of ModelRole.Accounts:
      result = newQVariant(item.accounts)
    of ModelRole.DerivedFrom:
      result = newQVariant(item.derivedFrom)

  proc findItemByPublicKey*(self: KeyPairModel, publicKey: string): KeyPairItem =
    for i in 0 ..< self.items.len:
      if(self.items[i].pubKey == publicKey):
        return self.items[i]
    return nil