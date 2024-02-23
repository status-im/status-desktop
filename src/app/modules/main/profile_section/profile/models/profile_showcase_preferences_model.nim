import NimQml, tables, strutils, sequtils, json

import profile_showcase_preferences_item
import app_service/service/profile/dto/profile_showcase_preferences

type
  ModelRole {.pure.} = enum
    ShowcaseKey
    ShowcaseVisibility
    ShowcasePosition

QtObject:
  type
    ProfileShowcasePreferencesModel* = ref object of QAbstractListModel
      items: seq[ProfileShowcasePreferencesItem]

  proc delete(self: ProfileShowcasePreferencesModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: ProfileShowcasePreferencesModel) =
    self.QAbstractListModel.setup

  proc newProfileShowcasePreferencesModel*(): ProfileShowcasePreferencesModel =
    new(result, delete)
    result.setup

  proc items*(self: ProfileShowcasePreferencesModel): seq[ProfileShowcasePreferencesItem] =
    self.items

  method rowCount(self: ProfileShowcasePreferencesModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcasePreferencesModel): Table[int, string] =
    {
      ModelRole.ShowcaseKey.int: "showcaseKey",
      ModelRole.ShowcaseVisibility.int: "showcaseVisibility",
      ModelRole.ShowcasePosition.int: "showcasePosition",
    }.toTable

  method data(self: ProfileShowcasePreferencesModel, index: QModelIndex, role: int): QVariant =
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

  proc findIndexByKey(self: ProfileShowcasePreferencesModel, key: string): int =
      for i in 0 ..< self.items.len:
        if (self.items[i].showcaseKey == key):
          return i
      return -1

  proc hasItemInShowcase*(self: ProfileShowcasePreferencesModel, key: string): bool {.slot.} =
    let index = self.findIndexByKey(key)
    if index == -1:
      return false
    return self.items[index].showcaseVisibility != ProfileShowcaseVisibility.ToNoOne

  proc appendItem*(self: ProfileShowcasePreferencesModel, item: ProfileShowcasePreferencesItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

  proc setItem*(self: ProfileShowcasePreferencesModel, index: int, item: ProfileShowcasePreferencesItem) =
    self.items[index] = item
    let modelIndex = self.createIndex(index, 0, nil)
    defer: modelIndex.delete
    self.dataChanged(modelIndex, modelIndex)

  proc upsertItem(self: ProfileShowcasePreferencesModel, item: ProfileShowcasePreferencesItem) =
    let index = self.findIndexByKey(item.showcaseKey)
    if index == -1:
      self.appendItem(item)
    else:
      self.setItem(index, item)

  proc setItems*(self: ProfileShowcasePreferencesModel, items: seq[ProfileShowcasePreferencesItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc clear*(self: ProfileShowcasePreferencesModel) {.slot.} =
    self.setItems(@[])
