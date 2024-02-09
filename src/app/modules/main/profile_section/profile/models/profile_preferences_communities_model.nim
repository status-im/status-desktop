import NimQml, tables, strutils, sequtils, json

import profile_preferences_community_item
import app_service/service/profile/dto/profile_showcase_preferences

type
  ModelRole {.pure.} = enum
    ShowcaseVisibility
    Order

    Id
    Name
    MemberRole
    Image
    Color
    Description
    MembersCount
    Loading

QtObject:
  type
    ProfileShowcaseCommunitiesModel* = ref object of QAbstractListModel
      items: seq[ProfileShowcaseCommunityItem]

  proc delete(self: ProfileShowcaseCommunitiesModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: ProfileShowcaseCommunitiesModel) =
    self.QAbstractListModel.setup

  proc newProfileShowcaseCommunitiesModel*(): ProfileShowcaseCommunitiesModel =
    new(result, delete)
    result.setup

  proc countChanged(self: ProfileShowcaseCommunitiesModel) {.signal.}
  proc getCount(self: ProfileShowcaseCommunitiesModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc hiddenCountChanged(self: ProfileShowcaseCommunitiesModel) {.signal.}
  proc getHiddenCount(self: ProfileShowcaseCommunitiesModel): int {.slot.} =
    result = 0
    for i, item in self.items:
      if item.showcaseVisibility == ProfileShowcaseVisibility.ToNoOne:
        result += 1
  QtProperty[int] hiddenCount:
    read = getHiddenCount
    notify = hiddenCountChanged

  proc recalcOrder(self: ProfileShowcaseCommunitiesModel) =
    for order, item in self.items:
      item.order = order

  proc items*(self: ProfileShowcaseCommunitiesModel): seq[ProfileShowcaseCommunityItem] =
    self.items

  method rowCount(self: ProfileShowcaseCommunitiesModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseCommunitiesModel): Table[int, string] =
    {
      ModelRole.Id.int: "id",
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",
      ModelRole.Name.int: "name",
      ModelRole.MemberRole.int: "memberRole",
      ModelRole.Image.int: "image",
      ModelRole.Color.int: "color",
      ModelRole.Description.int: "description",
      ModelRole.MembersCount.int: "membersCount",
      ModelRole.Loading.int: "loading",
    }.toTable

  method data(self: ProfileShowcaseCommunitiesModel, index: QModelIndex, role: int): QVariant =
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
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.MemberRole:
      result = newQVariant(item.memberRole.int)
    of ModelRole.Image:
      result = newQVariant(item.image)
    of ModelRole.Color:
      result = newQVariant(item.color)
    of ModelRole.Description:
      result = newQVariant(item.description)
    of ModelRole.MembersCount:
      result = newQVariant(item.membersCount)
    of ModelRole.Loading:
      result = newQVariant(item.loading)

  proc findIndexForCommunity(self: ProfileShowcaseCommunitiesModel, id: string): int =
    for i in 0 ..< self.items.len:
      if (self.items[i].id == id):
        return i
    return -1

  proc hasItemInShowcase*(self: ProfileShowcaseCommunitiesModel, id: string): bool {.slot.} =
    let ind = self.findIndexForCommunity(id)
    if ind == -1:
      return false
    return self.items[ind].showcaseVisibility != ProfileShowcaseVisibility.ToNoOne

  proc baseModelFilterConditionsMayHaveChanged*(self: ProfileShowcaseCommunitiesModel) {.signal.}

  proc appendItem*(self: ProfileShowcaseCommunitiesModel, item: ProfileShowcaseCommunityItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()
    self.hiddenCountChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItemImpl(self: ProfileShowcaseCommunitiesModel, item: ProfileShowcaseCommunityItem) =
    let ind = self.findIndexForCommunity(item.id)
    if ind == -1:
      self.appendItem(item)
    else:
      self.items[ind] = item

      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index)
      self.hiddenCountChanged()

  proc upsertItemJson(self: ProfileShowcaseCommunitiesModel, itemJson: string) {.slot.} =
    self.upsertItemImpl(itemJson.parseJson.toProfileShowcaseCommunityItem())
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItem*(self: ProfileShowcaseCommunitiesModel, item: ProfileShowcaseCommunityItem) =
    self.upsertItemImpl(item)
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc upsertItems*(self: ProfileShowcaseCommunitiesModel, items: seq[ProfileShowcaseCommunityItem]) =
    for item in items:
      self.upsertItemImpl(item)
    self.recalcOrder()
    self.baseModelFilterConditionsMayHaveChanged()

  proc reset*(self: ProfileShowcaseCommunitiesModel, items: seq[ProfileShowcaseCommunityItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
    self.hiddenCountChanged()
    self.baseModelFilterConditionsMayHaveChanged()

  proc clear*(self: ProfileShowcaseCommunitiesModel) {.slot.} =
    self.reset(@[])

  proc remove*(self: ProfileShowcaseCommunitiesModel, index: int) {.slot.} =
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

  proc removeEntry*(self: ProfileShowcaseCommunitiesModel, id: string) {.slot.} =
    let ind = self.findIndexForCommunity(id)
    if ind != -1:
      self.remove(ind)

  proc move*(self: ProfileShowcaseCommunitiesModel, fromRow: int, toRow: int, dummyCount: int = 1) {.slot.} =
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

  proc setVisibilityByIndex*(self: ProfileShowcaseCommunitiesModel, ind: int, visibility: int) {.slot.} =
    if (visibility >= ord(low(ProfileShowcaseVisibility)) and
        visibility <= ord(high(ProfileShowcaseVisibility)) and
        ind >= 0 and ind < self.items.len):
      self.items[ind].showcaseVisibility = ProfileShowcaseVisibility(visibility)
      let index = self.createIndex(ind, 0, nil)
      defer: index.delete
      self.dataChanged(index, index, @[ModelRole.ShowcaseVisibility.int])
      self.baseModelFilterConditionsMayHaveChanged()
      self.hiddenCountChanged()

  proc setVisibility*(self: ProfileShowcaseCommunitiesModel, id: string, visibility: int) {.slot.} =
    let index = self.findIndexForCommunity(id)
    if index != -1:
      self.setVisibilityByIndex(index, visibility)
