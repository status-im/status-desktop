import NimQml, tables, strutils, sequtils, sugar, json

import profile_preferences_community_item
import app_service/service/profile/dto/profile_showcase_entry

type
  ModelRole {.pure.} = enum
    ShowcaseVisibility
    Order

    Id
    Name
    MemberRole
    Image
    Color

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

  proc setItems*(self: ProfileShowcaseCommunitiesModel, items: seq[ProfileShowcaseCommunityItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

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
    }.toTable

  method data(self: ProfileShowcaseCommunitiesModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.ShowcaseVisibility:
      result = newQVariant(item.showcaseVisibility.int)
    of ModelRole.Order:
      result = newQVariant(item.order)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.MemberRole:
      result = newQVariant(item.memberRole.int)
    of ModelRole.Image:
      result = newQVariant(item.image)
    of ModelRole.Color:
      result = newQVariant(item.color)

  proc hasItem(self: ProfileShowcaseCommunitiesModel, id: string): bool {.slot.} =
    for item in self.items:
      if item.id == id:
        return true
    return false

  proc append(self: ProfileShowcaseCommunitiesModel, item: string) {.slot.} =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item.parseJson.toProfileShowcaseCommunityItem())
    self.endInsertRows()
    self.countChanged()

  proc remove*(self: ProfileShowcaseCommunitiesModel, index: int) {.slot.} =
    if index < 0 or index >= self.items.len:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()
    self.countChanged()

  proc setVisibility*(self: ProfileShowcaseCommunitiesModel, id: string, visibility: int) {.slot.} =
    if (visibility >= ord(low(ProfileShowcaseVisibility)) and visibility <= ord(high(ProfileShowcaseVisibility))):
      for i in 0 ..< self.items.len:
        if self.items[i].id == id:
          self.items[i].showcaseVisibility = ProfileShowcaseVisibility(visibility)
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index, @[ModelRole.ShowcaseVisibility.int])