import NimQml, tables, strutils, sequtils, json

import app_service/service/profile/dto/profile_showcase_preferences

type
  ShowcasePreferencesGenericItem* = object of RootObj
    showcaseKey*: string
    showcaseVisibility*: ProfileShowcaseVisibility
    showcasePosition*: int

type
  ModelRole {.pure.} = enum
    ShowcaseKey
    ShowcaseVisibility
    ShowcasePosition

QtObject:
  type
    ShowcasePreferencesGenericModel* = ref object of QAbstractListModel
      items: seq[ShowcasePreferencesGenericItem]

  proc delete(self: ShowcasePreferencesGenericModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: ShowcasePreferencesGenericModel) =
    self.QAbstractListModel.setup

  proc newShowcasePreferencesGenericModel*(): ShowcasePreferencesGenericModel =
    new(result, delete)
    result.setup

  proc items*(self: ShowcasePreferencesGenericModel): seq[ShowcasePreferencesGenericItem] =
    self.items

  method rowCount(self: ShowcasePreferencesGenericModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ShowcasePreferencesGenericModel): Table[int, string] =
    {
      ModelRole.ShowcaseKey.int: "showcaseKey",
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.ShowcasePosition.int: "showcasePosition",
    }.toTable

  method data(self: ShowcasePreferencesGenericModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ShowcaseKey:
      result = newQVariant(item.showcaseKey)
    of ModelRole.ShowcaseVisibility:
      result = newQVariant(item.showcaseVisibility.int)
    of ModelRole.ShowcasePosition:
      result = newQVariant(item.showcasePosition)

  proc setItems*(self: ShowcasePreferencesGenericModel, items: seq[ShowcasePreferencesGenericItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc clear*(self: ShowcasePreferencesGenericModel) {.slot.} =
    self.setItems(@[])
