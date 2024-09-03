import NimQml, Tables, strutils, stew/shims/strformat, std/sequtils

import ./item
import ../../../shared_models/currency_amount

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Address,
    Path,
    ColorId,
    WalletType,
    CurrencyBalance,
    Emoji,
    KeyUid,
    CreatedAt,
    Position,
    KeycardAccount,
    AssetsLoading,
    IsWallet,
    PreferredSharingChainIds,
    HideFromTotalBalance,
    CanSend

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
      ModelRole.ColorId.int:"colorId",
      ModelRole.WalletType.int:"walletType",
      ModelRole.CurrencyBalance.int:"currencyBalance",
      ModelRole.Emoji.int: "emoji",
      ModelRole.KeyUid.int: "keyUid",
      ModelRole.CreatedAt.int: "createdAt",
      ModelRole.Position.int: "position",
      ModelRole.KeycardAccount.int: "keycardAccount",
      ModelRole.AssetsLoading.int: "assetsLoading",
      ModelRole.IsWallet.int: "isWallet",
      ModelRole.PreferredSharingChainIds.int: "preferredSharingChainIds",
      ModelRole.HideFromTotalBalance.int: "hideFromTotalBalance",
      ModelRole.CanSend.int: "canSend"
    }.toTable

  proc removeItemWithIndex(self: Model, index: int) =
    if (index < 0 or index >= self.items.len):
      return
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()

  proc insertItem(self: Model, item: Item, index: int) =
    if (index < 0 or index > self.items.len):
      return
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, index, index)
    self.items.insert(item, index)
    self.endInsertRows()

  proc findAccountIndex(self: Model, account: Item): int =
    for i in 0 ..< self.items.len:
      if self.items[i].address() == account.address():
        return i
    return -1

  proc setItems*(self: Model, items: seq[Item]) =
    var indexesToRemove: seq[int]

    #remove
    for i in 0 ..< self.items.len:
      if not items.anyIt(it.address() == self.items[i].address()):
        indexesToRemove.add(i)

    while indexesToRemove.len > 0:
      let index = pop(indexesToRemove)
      self.removeItemWithIndex(index)

    # Update or insert
    for i in 0 ..< items.len:
      var account = items[i]
      let index = self.findAccountIndex(account)
      if index >= 0:
        let qIndex = self.createIndex(i, 0, nil)
        defer: qIndex.delete

        self.items[index] = account
        self.dataChanged(qIndex, qIndex)
        continue
      self.insertItem(account, i)
      
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
    of ModelRole.ColorId:
      result = newQVariant(item.colorId())
    of ModelRole.WalletType:
      result = newQVariant(item.walletType())
    of ModelRole.CurrencyBalance:
      result = newQVariant(item.currencyBalance())
    of ModelRole.Emoji:
      result = newQVariant(item.emoji())
    of ModelRole.KeyUid:
      result = newQVariant(item.keyUid())
    of ModelRole.CreatedAt:
      result = newQVariant(item.createdAt())
    of ModelRole.Position:
      result = newQVariant(item.getPosition())
    of ModelRole.KeycardAccount:
      result = newQVariant(item.keycardAccount())
    of ModelRole.AssetsLoading:
      result = newQVariant(item.assetsLoading())
    of ModelRole.IsWallet:
      result = newQVariant(item.isWallet())
    of ModelRole.PreferredSharingChainIds:
      result = newQVariant(item.preferredSharingChainIds())
    of ModelRole.HideFromTotalBalance:
      result = newQVariant(item.hideFromTotalBalance())
    of ModelRole.CanSend:
      result = newQVariant(item.canSend())

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
        return item.colorId()
    return ""

  proc isOwnedAccount*(self: Model, address: string): bool =
    for item in self.items:
      if cmpIgnoreCase(item.address(), address) == 0 and item.walletType != "watch":
        return true
    return false

  proc onPreferredSharingChainsUpdated*(self: Model, address, prodPreferredChainIds, testPreferredChainIds: string) =
    var i = 0
    for item in self.items.mitems:
      if address == item.address:
        item.prodPreferredChainIds = prodPreferredChainIds
        item.testPreferredChainIds = testPreferredChainIds
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.PreferredSharingChainIds.int])
        break
      i.inc