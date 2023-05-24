import NimQml, Tables, strutils, strformat, macros

import ./item
import ../../../shared_models/currency_amount
import ../../../shared_models/token_model

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Address,
    Path,
    Color,
    WalletType,
    CurrencyBalance,
    Emoji,
    KeyUid,
    KeycardAccount,
    AssetsLoading,

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
  proc itemChanged(self: Model, address: string) {.signal.}

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
      ModelRole.Color.int:"color",
      ModelRole.WalletType.int:"walletType",
      ModelRole.CurrencyBalance.int:"currencyBalance",
      ModelRole.Emoji.int: "emoji",
      ModelRole.KeyUid.int: "keyUid",
      ModelRole.KeycardAccount.int: "keycardAccount",
      ModelRole.AssetsLoading.int: "assetsLoading",
    }.toTable


  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

    for item in items:
      self.itemChanged(item.address())

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
    of ModelRole.Color:
      result = newQVariant(item.color())
    of ModelRole.WalletType:
      result = newQVariant(item.walletType())
    of ModelRole.CurrencyBalance:
      result = newQVariant(item.currencyBalance())
    of ModelRole.Emoji:
      result = newQVariant(item.emoji())
    of ModelRole.KeyUid:
      result = newQVariant(item.keyUid())
    of ModelRole.KeycardAccount:
      result = newQVariant(item.keycardAccount())
    of ModelRole.AssetsLoading:
      result = newQVariant(item.assetsLoading())

  proc getNameByAddress*(self: Model, address: string): string =
    for item in self.items:
      if(cmpIgnoreCase(item.address(), address) == 0):
        return item.name()
    return ""

  proc getEmojiByAddress*(self: Model, address: string): string =
    for item in self.items:
      if(cmpIgnoreCase(item.address(), address) == 0):
        return item.emoji()
    return ""

  proc getColorByAddress*(self: Model, address: string): string =
    for item in self.items:
      if(cmpIgnoreCase(item.address(), address) == 0):
        return item.color()
    return ""
