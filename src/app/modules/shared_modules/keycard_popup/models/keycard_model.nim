import NimQml, Tables, strformat
import keycard_item

export keycard_item

type
  ModelRole {.pure.} = enum
    PubKey = UserRole + 1
    KeycardUid
    Locked
    Name
    Image
    Icon
    PairType
    Accounts
    DerivedFrom

QtObject:
  type
    KeycardModel* = ref object of QAbstractListModel
      items: seq[KeycardItem]

  proc delete(self: KeycardModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: KeycardModel) =
    self.QAbstractListModel.setup

  proc newKeycardModel*(): KeycardModel =
    new(result, delete)
    result.setup

  proc countChanged(self: KeycardModel) {.signal.}
  proc getCount*(self: KeycardModel): int {.slot.} =
    self.items.len
  QtProperty[int]count:
    read = getCount
    notify = countChanged

  proc setItems*(self: KeycardModel, items: seq[KeycardItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc `$`*(self: KeycardModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""KeycardModel:
      [{i}]:({$self.items[i]})
      """

  method rowCount(self: KeycardModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: KeycardModel): Table[int, string] =
    {
      ModelRole.PubKey.int: "pubKey",
      ModelRole.KeycardUid.int: "keycardUid",
      ModelRole.Locked.int: "locked",
      ModelRole.Name.int: "name",
      ModelRole.Image.int: "image",
      ModelRole.Icon.int: "icon",
      ModelRole.PairType.int: "pairType",
      ModelRole.Accounts.int: "accounts",
      ModelRole.DerivedFrom.int: "derivedFrom"
    }.toTable

  method data(self: KeycardModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return
    if (index.row < 0 or index.row >= self.items.len):
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
    of ModelRole.PubKey:
      result = newQVariant(item.pubKey)
    of ModelRole.KeycardUid:
      result = newQVariant(item.keycardUid)
    of ModelRole.Locked:
      result = newQVariant(item.locked)
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

  proc getItemByKeycardUid*(self: KeycardModel, keycardUid: string): KeycardItem =
    for i in 0 ..< self.items.len:
      if(self.items[i].keycardUid == keycardUid):
        return self.items[i]
    return nil

  proc findIndexForMember(self: KeycardModel, pubKey: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].pubKey == pubKey):
        return i
    return -1

  proc setImage*(self: KeycardModel, pubKey: string, image: string) =
    let ind = self.findIndexForMember(pubKey)
    if(ind == -1):
      return
    self.items[ind].setImage(image)
    let index = self.createIndex(ind, 0, nil)
    self.dataChanged(index, index, @[ModelRole.Image.int])

  proc setLocked*(self: KeycardModel, keycardUid: string, locked: bool) =
    for i in 0 ..< self.items.len:
      if(self.items[i].keycardUid == keycardUid):
        self.items[i].setLocked(locked)
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.Locked.int])

  proc setName*(self: KeycardModel, keycardUid: string, name: string) =
    for i in 0 ..< self.items.len:
      if(self.items[i].keycardUid == keycardUid):
        self.items[i].setName(name)
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.Name.int])

  proc setKeycardUid*(self: KeycardModel, keycardUid: string, keycardNewUid: string) =
    for i in 0 ..< self.items.len:
      if(self.items[i].keycardUid == keycardUid):
        self.items[i].setKeycardUid(keycardNewUid)
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.KeycardUid.int])