import NimQml, tables, strutils, sequtils, json

import profile_preferences_collectible_item
import app_service/service/profile/dto/profile_showcase_preferences

type
  ModelRole {.pure.} = enum
    ShowcaseVisibility = UserRole + 1
    Order

    Uid
    Name
    CollectionName
    ImageUrl
    BackgroundColor

QtObject:
  type
    ProfileShowcaseCollectiblesModel* = ref object of QAbstractListModel
      items: seq[ProfileShowcaseCollectibleItem]

  proc delete(self: ProfileShowcaseCollectiblesModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: ProfileShowcaseCollectiblesModel) =
    self.QAbstractListModel.setup

  proc newProfileShowcaseCollectiblesModel*(): ProfileShowcaseCollectiblesModel =
    new(result, delete)
    result.setup

  proc countChanged(self: ProfileShowcaseCollectiblesModel) {.signal.}
  proc getCount(self: ProfileShowcaseCollectiblesModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc recalcOrder(self: ProfileShowcaseCollectiblesModel) =
    for order, item in self.items:
      item.order = order

  proc items*(self: ProfileShowcaseCollectiblesModel): seq[ProfileShowcaseCollectibleItem] =
    self.items

  method rowCount(self: ProfileShowcaseCollectiblesModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseCollectiblesModel): Table[int, string] =
    {
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",

      ModelRole.Uid.int: "uid",
      ModelRole.Name.int: "name",
      ModelRole.CollectionName.int: "collectionName",
      ModelRole.ImageUrl.int: "imageUrl",
      ModelRole.BackgroundColor.int: "backgroundColor",
    }.toTable

  method data(self: ProfileShowcaseCollectiblesModel, index: QModelIndex, role: int): QVariant =
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
    of ModelRole.Uid:
      result = newQVariant(item.uid)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.CollectionName:
      result = newQVariant(item.collectionName)
    of ModelRole.ImageUrl:
      result = newQVariant(item.imageUrl)
    of ModelRole.BackgroundColor:
      result = newQVariant(item.backgroundColor)

  proc findIndexForCollectible(self: ProfileShowcaseCollectiblesModel, uid: string): int =
    for i in 0 ..< self.items.len:
      if (self.items[i].uid == uid):
        return i
    return -1

  proc hasItemInShowcase*(self: ProfileShowcaseCollectiblesModel, uid: string): bool {.slot.} =
    let ind = self.findIndexForCollectible(uid)
    if ind == -1:
      return false
    return self.items[ind].showcaseVisibility != ProfileShowcaseVisibility.ToNoOne

  proc baseModelFilterConditionsMayHaveChanged*(self: ProfileShowcaseCollectiblesModel) {.signal.}

  proc appendItem*(self: ProfileShowcaseCollectiblesModel, item: ProfileShowcaseCollectibleItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItemImpl(self: ProfileShowcaseCollectiblesModel, item: ProfileShowcaseCollectibleItem) =
    let ind = self.findIndexForCollectible(item.uid)
    if ind == -1:
      self.appendItem(item)
    else:
      self.items[ind] = item

      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index, @[
        ModelRole.ShowcaseVisibility.int,
        ModelRole.Order.int,
        ModelRole.Uid.int,
        ModelRole.Name.int,
        ModelRole.CollectionName.int,
        ModelRole.ImageUrl.int,
        ModelRole.BackgroundColor.int,
      ])

  proc upsertItemJson(self: ProfileShowcaseCollectiblesModel, itemJson: string) {.slot.} =
    self.upsertItemImpl(itemJson.parseJson.toProfileShowcaseCollectibleItem())
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItem*(self: ProfileShowcaseCollectiblesModel, item: ProfileShowcaseCollectibleItem) =
    self.upsertItemImpl(item)
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItems*(self: ProfileShowcaseCollectiblesModel, items: seq[ProfileShowcaseCollectibleItem]) =
    for item in items:
      self.upsertItemImpl(item)
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc reset*(self: ProfileShowcaseCollectiblesModel, items: seq[ProfileShowcaseCollectibleItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc clear*(self: ProfileShowcaseCollectiblesModel) {.slot.} =
    self.reset(@[])

  proc remove*(self: ProfileShowcaseCollectiblesModel, index: int) {.slot.} =
    if index < 0 or index >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc removeEntry*(self: ProfileShowcaseCollectiblesModel, uid: string) {.slot.} =
    let ind = self.findIndexForCollectible(uid)
    if ind != -1:
      self.remove(ind)

  proc move*(self: ProfileShowcaseCollectiblesModel, fromIndex: int, toIndex: int) {.slot.} =
    if fromIndex < 0 or fromIndex >= self.items.len:
      return

    self.beginResetModel()
    let item = self.items[fromIndex]
    self.items.delete(fromIndex)
    self.items.insert(@[item], toIndex)
    self.recalcOrder()
    self.endResetModel()

  proc setVisibilityByIndex*(self: ProfileShowcaseCollectiblesModel, ind: int, visibility: int) {.slot.} =
    if (visibility >= ord(low(ProfileShowcaseVisibility)) and
        visibility <= ord(high(ProfileShowcaseVisibility)) and
        ind >= 0 and ind < self.items.len):
      self.items[ind].showcaseVisibility = ProfileShowcaseVisibility(visibility)
      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index, @[ModelRole.ShowcaseVisibility.int])
      self.baseModelFilterConditionsMayHaveChanged()

  proc setVisibility*(self: ProfileShowcaseCollectiblesModel, uid: string, visibility: int) {.slot.} =
    let index = self.findIndexForCollectible(uid)
    if index != -1:
      self.setVisibilityByIndex(index, visibility)