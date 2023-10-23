import NimQml, tables, strutils, sequtils, sugar, json

import profile_preferences_account_item
import app_service/service/profile/dto/profile_showcase_entry

type
  ModelRole {.pure.} = enum
    ShowcaseVisibility = UserRole + 1
    Order

    Address
    Name
    Emoji
    WalletType
    ColorId

QtObject:
  type
    ProfileShowcaseAccountsModel* = ref object of QAbstractListModel
      items: seq[ProfileShowcaseAccountItem]

  proc delete(self: ProfileShowcaseAccountsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: ProfileShowcaseAccountsModel) =
    self.QAbstractListModel.setup

  proc newProfileShowcaseAccountsModel*(): ProfileShowcaseAccountsModel =
    new(result, delete)
    result.setup

  proc countChanged(self: ProfileShowcaseAccountsModel) {.signal.}
  proc getCount(self: ProfileShowcaseAccountsModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc setItems*(self: ProfileShowcaseAccountsModel, items: seq[ProfileShowcaseAccountItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc items*(self: ProfileShowcaseAccountsModel): seq[ProfileShowcaseAccountItem] =
    self.items

  method rowCount(self: ProfileShowcaseAccountsModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseAccountsModel): Table[int, string] =
    {
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",

      ModelRole.Address.int: "address",
      ModelRole.Name.int: "name",
      ModelRole.WalletType.int: "walletType",
      ModelRole.Emoji.int: "emoji",
      ModelRole.ColorId.int: "colorId",
    }.toTable

  method data(self: ProfileShowcaseAccountsModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Address:
      result = newQVariant(item.address)
    of ModelRole.ShowcaseVisibility:
      result = newQVariant(item.showcaseVisibility.int)
    of ModelRole.Order:
      result = newQVariant(item.order)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.WalletType:
      result = newQVariant(item.walletType)
    of ModelRole.Emoji:
      result = newQVariant(item.emoji)
    of ModelRole.ColorId:
      result = newQVariant(item.colorId)

  proc hasItem(self: ProfileShowcaseAccountsModel, address: string): bool {.slot.} =
    for item in self.items:
      if item.address == address:
        return true
    return false

  proc append(self: ProfileShowcaseAccountsModel, item: string) {.slot.} =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item.parseJson.toProfileShowcaseAccountItem())
    self.endInsertRows()
    self.countChanged()

  proc remove*(self: ProfileShowcaseAccountsModel, index: int) {.slot.} =
    if index < 0 or index >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc setVisibility*(self: ProfileShowcaseAccountsModel, address: string, visibility: int) {.slot.} =
    if (visibility >= ord(low(ProfileShowcaseVisibility)) and visibility <= ord(high(ProfileShowcaseVisibility))):
      for i in 0 ..< self.items.len:
        if self.items[i].address == address:
          self.items[i].showcaseVisibility = ProfileShowcaseVisibility(visibility)
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index, @[ModelRole.ShowcaseVisibility.int])

