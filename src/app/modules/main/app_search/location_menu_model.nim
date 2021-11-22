import NimQml, Tables, strutils

import location_menu_item, location_menu_sub_item

type
  ModelRole {.pure.} = enum
    Value = UserRole + 1
    Title
    ImageSource
    IconName
    IconColor
    IsIdenticon
    SubItems

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    for i in 0 ..< self.items.len:
      self.items[i].delete
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup()

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Value.int:"value",
      ModelRole.Title.int:"title",
      ModelRole.ImageSource.int:"imageSource",
      ModelRole.IconName.int:"iconName",
      ModelRole.IconColor.int:"iconColor",
      ModelRole.IsIdenticon.int:"isIdenticon",
      ModelRole.SubItems.int:"subItems"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Value: 
      result = newQVariant(item.value)
    of ModelRole.Title: 
      result = newQVariant(item.text)
    of ModelRole.ImageSource: 
      result = newQVariant(item.image)
    of ModelRole.IconName: 
      result = newQVariant(item.icon)
    of ModelRole.IconColor: 
      result = newQVariant(item.iconColor)
    of ModelRole.IsIdenticon: 
      result = newQVariant(item.isIdenticon)
    of ModelRole.SubItems: 
      result = newQVariant(item.subItems)

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc getItemForValue*(self: Model, value: string): Item =
    for i in self.items:
      if (i.value == value):
        return i
