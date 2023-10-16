import NimQml, tables, strutils, sequtils, sugar

import profile_preferences_asset_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    EntryType
    ShowcaseVisibility
    Order

    Name
    EnabledNetworkBalance
    Symbol
    Color

QtObject:
  type
    ProfileShowcaseAssetsModel* = ref object of QAbstractListModel
      items: seq[ProfileShowcaseAssetItem]

  proc delete(self: ProfileShowcaseAssetsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: ProfileShowcaseAssetsModel) =
    self.QAbstractListModel.setup

  proc newProfileShowcaseAssetsModel*(): ProfileShowcaseAssetsModel =
    new(result, delete)
    result.setup

  proc countChanged(self: ProfileShowcaseAssetsModel) {.signal.}
  proc getCount(self: ProfileShowcaseAssetsModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc setItems*(self: ProfileShowcaseAssetsModel, items: seq[ProfileShowcaseAssetItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc items*(self: ProfileShowcaseAssetsModel): seq[ProfileShowcaseAssetItem] =
    self.items

  method rowCount(self: ProfileShowcaseAssetsModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseAssetsModel): Table[int, string] =
    {
      ModelRole.Id.int: "id",
      ModelRole.EntryType.int: "entryType",
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",
      ModelRole.Name.int: "name",
      ModelRole.EnabledNetworkBalance.int: "enabledNetworkBalance",
      ModelRole.Symbol.int: "symbol",
      ModelRole.Color.int: "color",
    }.toTable

  method data(self: ProfileShowcaseAssetsModel, index: QModelIndex, role: int): QVariant =
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
    of ModelRole.EnabledNetworkBalance:
      result = newQVariant(item.enabledNetworkBalance)
    of ModelRole.Symbol:
      result = newQVariant(item.symbol)
    of ModelRole.Color:
      result = newQVariant(item.color)
