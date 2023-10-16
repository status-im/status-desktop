import NimQml, tables, strutils, sequtils, sugar

import profile_preferences_collectible_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    EntryType
    ShowcaseVisibility
    Order

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

  proc setItems*(self: ProfileShowcaseCollectiblesModel, items: seq[ProfileShowcaseCollectibleItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc items*(self: ProfileShowcaseCollectiblesModel): seq[ProfileShowcaseCollectibleItem] =
    self.items

  method rowCount(self: ProfileShowcaseCollectiblesModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcaseCollectiblesModel): Table[int, string] =
    {
      ModelRole.Id.int: "id",
      ModelRole.EntryType.int: "entryType",
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.Order.int: "order",
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
    of ModelRole.CollectionName:
      result = newQVariant(item.collectionName)
    of ModelRole.ImageUrl:
      result = newQVariant(item.imageUrl)
    of ModelRole.BackgroundColor:
      result = newQVariant(item.backgroundColor)
