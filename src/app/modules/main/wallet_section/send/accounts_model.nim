import NimQml, Tables, strutils, strformat

import ./account_item
import ../../../shared_models/currency_amount

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1,
    Address,
    Color,
    WalletType,
    Emoji,
    Assets,
    CurrencyBalance,

QtObject:
  type
    AccountsModel* = ref object of QAbstractListModel
      items*: seq[AccountItem]

  proc delete(self: AccountsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: AccountsModel) =
    self.QAbstractListModel.setup

  proc newAccountsModel*(): AccountsModel =
    new(result, delete)
    result.setup

  proc `$`*(self: AccountsModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: AccountsModel) {.signal.}

  proc getCount*(self: AccountsModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: AccountsModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: AccountsModel): Table[int, string] =
    {
      ModelRole.Name.int:"name",
      ModelRole.Address.int:"address",
      ModelRole.Color.int:"color",
      ModelRole.WalletType.int:"walletType",
      ModelRole.Emoji.int: "emoji",
      ModelRole.Assets.int: "assets",
      ModelRole.CurrencyBalance.int: "currencyBalance",
    }.toTable


  proc setItems*(self: AccountsModel, items: seq[AccountItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  method data(self: AccountsModel, index: QModelIndex, role: int): QVariant =
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
    of ModelRole.Color:
      result = newQVariant(item.color())
    of ModelRole.WalletType:
      result = newQVariant(item.walletType())
    of ModelRole.Emoji:
      result = newQVariant(item.emoji())
    of ModelRole.Assets:
      result = newQVariant(item.assets())
    of ModelRole.CurrencyBalance:
      result = newQVariant(item.currencyBalance())
    
