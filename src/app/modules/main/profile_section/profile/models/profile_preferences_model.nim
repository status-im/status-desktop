import NimQml, tables, strutils, sequtils, sugar

import profile_preferences_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    EntryType
    Visibility
    Order

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

  proc countChanged(self: ProfileShowcasePreferencesModel) {.signal.}
  proc getCount(self: ProfileShowcasePreferencesModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  proc setItems*(self: ProfileShowcasePreferencesModel, items: seq[ProfileShowcasePreferencesItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc appendItem*(self: ProfileShowcasePreferencesModel, item: ProfileShowcasePreferencesItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete
    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc removeItem*(self: ProfileShowcasePreferencesModel, id: string): bool =
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

  proc updateItem*(self: ProfileShowcasePreferencesModel, item: ProfileShowcasePreferencesItem): bool =
    for i in 0 ..< self.items.len:
      if (self.items[i].id == item.id):
        self.items[i] = item
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.EntryType.int, ModelRole.Visibility.int, ModelRole.Order.int])
        return true

    return false

  proc items*(self: ProfileShowcasePreferencesModel): seq[ProfileShowcasePreferencesItem] =
    self.items

  method rowCount(self: ProfileShowcasePreferencesModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: ProfileShowcasePreferencesModel): Table[int, string] =
    {
      ModelRole.Id.int: "id",
      ModelRole.EntryType.int: "entryType",
      ModelRole.Visibility.int: "visibility",
      ModelRole.Order.int: "order",
    }.toTable

  method data(self: ProfileShowcasePreferencesModel, index: QModelIndex, role: int): QVariant =
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
    of ModelRole.Visibility:
      result = newQVariant(item.visibility.int)
    of ModelRole.Order:
      result = newQVariant(item.order)
