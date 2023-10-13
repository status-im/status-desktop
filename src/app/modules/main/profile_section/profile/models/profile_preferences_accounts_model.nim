import NimQml, tables, strutils, sequtils, sugar

import profile_preferences_account_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    EntryType
    ShowcaseVisibility
    Order

    Name
    Address
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

  proc removeItem*(self: ProfileShowcaseAccountsModel, id: string): bool =
    for i in 0 ..< self.items.len:
      if (self.items[i].id == id):
        let parentModelIndex = newQModelIndex()
        defer: parentModelIndex.delete
        self.beginRemoveRows(parentModelIndex, i, i)
        self.items.delete(i)
        self.endRemoveRows()
        self.countChanged()
        return true
    return false

  proc updateItem*(self: ProfileShowcaseAccountsModel, item: ProfileShowcaseAccountItem): bool =
    for i in 0 ..< self.items.len:
      if (self.items[i].id == item.id):
        self.items[i] = item
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.EntryType.int, ModelRole.ShowcaseVisibility.int, ModelRole.Order.int])
        return true

    return false

  proc items*(self: ProfileShowcaseAccountsModel): seq[ProfileShowcaseAccountItem] =
    self.items

  method rowCount(self: ProfileShowcaseAccountsModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseAccountsModel): Table[int, string] =
    {
      ModelRole.Id.int: "id",
      ModelRole.EntryType.int: "entryType",
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",

      ModelRole.Name.int: "name",
      ModelRole.Address.int: "address",
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
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.EntryType:
      result = newQVariant(item.entryType.int)
    of ModelRole.ShowcaseVisibility:
      result = newQVariant(item.showcaseVisibility.int)
    of ModelRole.Order:
      result = newQVariant(item.order)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.Address:
      result = newQVariant(item.address)
    of ModelRole.WalletType:
      result = newQVariant(item.walletType)
    of ModelRole.Emoji:
      result = newQVariant(item.emoji)
    of ModelRole.ColorId:
      result = newQVariant(item.colorId)
