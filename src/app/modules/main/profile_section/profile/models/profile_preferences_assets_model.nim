import NimQml, tables, strutils, sequtils, json

import profile_preferences_asset_item
import app_service/service/profile/dto/profile_showcase_preferences

type
  ModelRole {.pure.} = enum
    ShowcaseVisibility = UserRole + 1
    Order

    Address
    CommunityId
    Symbol
    Name
    EnabledNetworkBalance
    Decimals

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

  proc hiddenCountChanged(self: ProfileShowcaseAssetsModel) {.signal.}
  proc getHiddenCount(self: ProfileShowcaseAssetsModel): int {.slot.} =
    result = 0
    for i, item in self.items:
      if item.showcaseVisibility == ProfileShowcaseVisibility.ToNoOne:
        result += 1
  QtProperty[int] hiddenCount:
    read = getHiddenCount
    notify = hiddenCountChanged

  proc recalcOrder(self: ProfileShowcaseAssetsModel) =
    for order, item in self.items:
      item.order = order

  proc items*(self: ProfileShowcaseAssetsModel): seq[ProfileShowcaseAssetItem] =
    self.items

  method rowCount(self: ProfileShowcaseAssetsModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseAssetsModel): Table[int, string] =
    {
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",

      ModelRole.Address.int: "address",
      ModelRole.CommunityId.int: "communityId",
      ModelRole.Symbol.int: "symbol",
      ModelRole.Name.int: "name",
      ModelRole.EnabledNetworkBalance.int: "enabledNetworkBalance",
      ModelRole.Decimals.int: "decimals",
    }.toTable

  method data(self: ProfileShowcaseAssetsModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ShowcaseVisibility:
      result = newQVariant(item.showcaseVisibility.int)
    of ModelRole.Order:
      result = newQVariant(item.order)
    of ModelRole.Address:
      result = newQVariant(item.contractAddress)
    of ModelRole.CommunityId:
      result = newQVariant(item.communityId)
    of ModelRole.Symbol:
      result = newQVariant(item.symbol)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.EnabledNetworkBalance:
      result = newQVariant(item.enabledNetworkBalance)
    of ModelRole.Decimals:
      result = newQVariant(item.decimals)

  proc findIndexForAsset(self: ProfileShowcaseAssetsModel, symbol: string): int =
    for i in 0 ..< self.items.len:
      if (self.items[i].symbol == symbol):
        return i
    return -1

  proc hasItemInShowcase*(self: ProfileShowcaseAssetsModel, symbol: string): bool {.slot.} =
    let ind = self.findIndexForAsset(symbol)
    if ind == -1:
      return false
    return self.items[ind].showcaseVisibility != ProfileShowcaseVisibility.ToNoOne

  proc baseModelFilterConditionsMayHaveChanged*(self: ProfileShowcaseAssetsModel) {.signal.}

  proc appendItem*(self: ProfileShowcaseAssetsModel, item: ProfileShowcaseAssetItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()
    self.hiddenCountChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItemImpl(self: ProfileShowcaseAssetsModel, item: ProfileShowcaseAssetItem) =
    let ind = self.findIndexForAsset(item.symbol)
    if ind == -1:
      self.appendItem(item)
    else:
      self.items[ind] = item

      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index)
      self.hiddenCountChanged()

  proc upsertItemJson(self: ProfileShowcaseAssetsModel, itemJson: string) {.slot.} =
    self.upsertItemImpl(itemJson.parseJson.toProfileShowcaseAssetItem())
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItem*(self: ProfileShowcaseAssetsModel, item: ProfileShowcaseAssetItem) =
    self.upsertItemImpl(item)
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItems*(self: ProfileShowcaseAssetsModel, items: seq[ProfileShowcaseAssetItem]) =
    for item in items:
      self.upsertItemImpl(item)
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc reset*(self: ProfileShowcaseAssetsModel, items: seq[ProfileShowcaseAssetItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
    self.hiddenCountChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc clear*(self: ProfileShowcaseAssetsModel) {.slot.} =
    self.reset(@[])

  proc remove*(self: ProfileShowcaseAssetsModel, index: int) {.slot.} =
    if index < 0 or index >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()
    self.hiddenCountChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc removeEntry*(self: ProfileShowcaseAssetsModel, symbol: string) {.slot.} =
    let ind = self.findIndexForAsset(symbol)
    if ind != -1:
      self.remove(ind)

  proc move*(self: ProfileShowcaseAssetsModel, fromRow: int, toRow: int, dummyCount: int = 1) {.slot.} =
    if fromRow < 0 or fromRow >= self.items.len:
      return

    let sourceIndex = newQModelIndex()
    defer: sourceIndex.delete
    let destIndex = newQModelIndex()
    defer: destIndex.delete

    var destRow = toRow
    if toRow > fromRow:
      inc(destRow)

    self.beginMoveRows(sourceIndex, fromRow, fromRow, destIndex, destRow)
    let item = self.items[fromRow]
    self.items.delete(fromRow)
    self.items.insert(@[item], toRow)
    self.recalcOrder()
    self.endMoveRows()

  proc setVisibilityByIndex*(self: ProfileShowcaseAssetsModel, ind: int, visibility: int) {.slot.} =
    if (visibility >= ord(low(ProfileShowcaseVisibility)) and
        visibility <= ord(high(ProfileShowcaseVisibility)) and
        ind >= 0 and ind < self.items.len):
      self.items[ind].showcaseVisibility = ProfileShowcaseVisibility(visibility)
      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index, @[ModelRole.ShowcaseVisibility.int])
      self.baseModelFilterConditionsMayHaveChanged()
      self.hiddenCountChanged()

  proc setVisibility*(self: ProfileShowcaseAssetsModel, symbol: string, visibility: int) {.slot.} =
    let index = self.findIndexForAsset(symbol)
    if index != -1:
      self.setVisibilityByIndex(index, visibility)
