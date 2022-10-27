import NimQml, Tables, strutils, strformat

import ./item

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Address,
    Path,
    Color,
    PublicKey,
    WalletType,
    IsWallet,
    IsChat,
    CurrencyBalance,
    Assets,
    Emoji,
    DerivedFrom,
    RelatedAccounts,
    KeyUid,
    MigratedToKeycard

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
      ModelRole.Color.int:"color",
      ModelRole.PublicKey.int:"publicKey",
      ModelRole.WalletType.int:"walletType",
      ModelRole.IsWallet.int:"isWallet",
      ModelRole.IsChat.int:"isChat",
      ModelRole.Assets.int:"assets",
      ModelRole.CurrencyBalance.int:"currencyBalance",
      ModelRole.Emoji.int: "emoji",
      ModelRole.DerivedFrom.int: "derivedfrom",
      ModelRole.RelatedAccounts.int: "relatedAccounts",
      ModelRole.KeyUid.int: "keyUid",
      ModelRole.MigratedToKeycard.int: "migratedToKeycard"
    }.toTable


  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Name:
      result = newQVariant(item.getName())
    of ModelRole.Address:
      result = newQVariant(item.getAddress())
    of ModelRole.Path:
      result = newQVariant(item.getPath())
    of ModelRole.Color:
      result = newQVariant(item.getColor())
    of ModelRole.PublicKey:
      result = newQVariant(item.getPublicKey())
    of ModelRole.WalletType:
      result = newQVariant(item.getWalletType())
    of ModelRole.IsWallet:
      result = newQVariant(item.getIsWallet())
    of ModelRole.IsChat:
      result = newQVariant(item.getIsChat())
    of ModelRole.CurrencyBalance:
      result = newQVariant(item.getCurrencyBalance())
    of ModelRole.Assets:
      result = newQVariant(item.getAssets())
    of ModelRole.Emoji:
      result = newQVariant(item.getEmoji())
    of ModelRole.DerivedFrom:
      result = newQVariant(item.getDerivedFrom())
    of ModelRole.RelatedAccounts:
      result = newQVariant(item.getRelatedAccounts())
    of ModelRole.KeyUid:
      result = newQVariant(item.getKeyUid())
    of ModelRole.MigratedToKeycard:
      result = newQVariant(item.getMigratedToKeycard())

  proc getAccountNameByAddress*(self: Model, address: string): string =
    for account in self.items:
      if(account.getAddress() == address):
        return account.getName()
    return ""

  proc getAccountIconColorByAddress*(self: Model, address: string): string =
    for account in self.items:
      if(account.getAddress() == address):
        return account.getColor()
    return ""

  proc getAccountAssetsByAddress*(self: Model, address: string): QVariant =
    for account in self.items:
      if(account.getAddress() == address):
        return newQVariant(account.getAssets())
    return nil
