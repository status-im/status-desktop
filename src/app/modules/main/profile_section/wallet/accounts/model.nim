import NimQml, Tables, strutils, strformat
import ./item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Address,
    Path,
    ColorId,
    WalletType,
    Emoji,
    RelatedAccounts,
    KeyUid,
    Position,

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

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: Model) {.signal.}

  proc getCount*(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.Address.int:"address",
      ModelRole.Path.int:"path",
      ModelRole.ColorId.int:"colorId",
      ModelRole.WalletType.int:"walletType",
      ModelRole.Emoji.int: "emoji",
      ModelRole.RelatedAccounts.int: "relatedAccounts",
      ModelRole.KeyUid.int: "keyUid",
      ModelRole.Position.int: "position",
    }.toTable


  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc onUpdatedAccount*(self: Model, account: Item) = 
    var i = 0
    for item in self.items.mitems:
      if account.address == item.address:
        item.name = account.name
        item.colorId = account.colorId
        item.emoji = account.emoji
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[ModelRole.Name.int])
        self.dataChanged(index, index, @[ModelRole.ColorId.int])
        self.dataChanged(index, index, @[ModelRole.Emoji.int])
        break
      i.inc

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Name:
      result = newQVariant(item.name())
    of ModelRole.Address:
      result = newQVariant(item.address())
    of ModelRole.Path:
      result = newQVariant(item.path())
    of ModelRole.ColorId:
      result = newQVariant(item.colorId())
    of ModelRole.WalletType:
      result = newQVariant(item.walletType())
    of ModelRole.Emoji:
      result = newQVariant(item.emoji())
    of ModelRole.RelatedAccounts:
      result = newQVariant(item.relatedAccounts())
    of ModelRole.KeyUid:
      result = newQVariant(item.keyUid())
    of ModelRole.Position:
      result = newQVariant(item.position())
