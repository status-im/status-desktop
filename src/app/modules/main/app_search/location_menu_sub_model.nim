import NimQml, Tables, strutils, strformat

import location_menu_sub_item

type
  SubModelRole {.pure.} = enum
    Value = UserRole + 1
    Text
    Image
    Icon
    IconColor
    IsUserIcon
    ColorId
    ColorHash

QtObject:
  type
    SubModel* = ref object of QAbstractListModel
      items: seq[SubItem]

  proc delete*(self: SubModel) =
    for i in 0 ..< self.items.len:
      self.items[i].delete
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: SubModel) =
    self.QAbstractListModel.setup

  proc newSubModel*(): SubModel =
    new(result, delete)
    result.setup()

  proc `$`*(self: SubModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged*(self: SubModel) {.signal.}

  proc count*(self: SubModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: SubModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: SubModel): Table[int, string] =
    {
      SubModelRole.Value.int:"value",
      SubModelRole.Text.int:"text",
      SubModelRole.Image.int:"imageSource",
      SubModelRole.Icon.int:"iconName",
      SubModelRole.IconColor.int:"iconColor",
      SubModelRole.IsUserIcon.int:"isUserIcon",
      SubModelRole.ColorId.int:"colorId",
      SubModelRole.ColorHash.int:"colorHash"
    }.toTable

  method data(self: SubModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.SubModelRole

    case enumRole:
    of SubModelRole.Value:
      result = newQVariant(item.value)
    of SubModelRole.Text:
      result = newQVariant(item.text)
    of SubModelRole.Image:
      result = newQVariant(item.image)
    of SubModelRole.Icon:
      result = newQVariant(item.icon)
    of SubModelRole.IconColor:
      result = newQVariant(item.iconColor)
    of SubModelRole.IsUserIcon:
      result = newQVariant(item.isUserIcon)
    of SubModelRole.ColorId:
      result = newQVariant(item.colorId)
    of SubModelRole.ColorHash:
      result = newQVariant(item.colorHash)

  proc setItems*(self: SubModel, items: seq[SubItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc getItemForValue*(self: SubModel, value: string): SubItem =
    for i in self.items:
      if (i.value == value):
        return i
