import NimQml, tables, strutils, sequtils, sugar, json

import profile_preferences_asset_item
import app_service/service/profile/dto/profile_showcase_entry

type
  ModelRole {.pure.} = enum
    ShowcaseVisibility = UserRole + 1
    Order

    Symbol
    Name
    EnabledNetworkBalance
    VisibleForNetworkWithPositiveBalance
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
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",

      ModelRole.Symbol.int: "symbol",
      ModelRole.Name.int: "name",
      ModelRole.EnabledNetworkBalance.int: "enabledNetworkBalance",
      ModelRole.VisibleForNetworkWithPositiveBalance.int: "visibleForNetworkWithPositiveBalance",
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
    of ModelRole.Symbol:
      result = newQVariant(item.symbol)
    of ModelRole.ShowcaseVisibility:
      result = newQVariant(item.showcaseVisibility.int)
    of ModelRole.Order:
      result = newQVariant(item.order)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.EnabledNetworkBalance:
      result = newQVariant(item.enabledNetworkBalance)
    of ModelRole.VisibleForNetworkWithPositiveBalance:
      result = newQVariant(item.visibleForNetworkWithPositiveBalance)
    of ModelRole.Color:
      result = newQVariant(item.color)

  proc hasItem(self: ProfileShowcaseAssetsModel, symbol: string): bool {.slot.} =
    for item in self.items:
      if item.symbol == symbol:
        return true
    return false

  proc append(self: ProfileShowcaseAssetsModel, item: string) {.slot.} =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item.parseJson.toProfileShowcaseAssetItem())
    self.endInsertRows()
    self.countChanged()

  proc remove*(self: ProfileShowcaseAssetsModel, index: int) {.slot.} =
    if index < 0 or index >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc setVisibility*(self: ProfileShowcaseAssetsModel, symbol: string, visibility: int) {.slot.} =
    if (visibility >= ord(low(ProfileShowcaseVisibility)) and visibility <= ord(high(ProfileShowcaseVisibility))):
      for i in 0 ..< self.items.len:
        if self.items[i].symbol == symbol:
          self.items[i].showcaseVisibility = ProfileShowcaseVisibility(visibility)
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index, @[ModelRole.ShowcaseVisibility.int])
