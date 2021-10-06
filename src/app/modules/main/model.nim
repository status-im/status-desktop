import NimQml, Tables, strutils, strformat

import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    Image
    Icon
    Color
    MentionsCount
    UnviewedMessagesCount

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged(self: Model) {.signal.}

  proc getCount(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.Name.int:"name",
      ModelRole.Image.int:"image",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.MentionsCount.int:"mentionsCount",
      ModelRole.UnviewedMessagesCount.int:"unviewedMessagesCount"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id: 
      result = newQVariant(item.getId())
    of ModelRole.Name: 
      result = newQVariant(item.getName())
    of ModelRole.Image: 
      result = newQVariant(item.getImage())
    of ModelRole.Icon: 
      result = newQVariant(item.getIcon())
    of ModelRole.Color: 
      result = newQVariant(item.getColor())
    of ModelRole.MentionsCount: 
      result = newQVariant(item.getMentionsCount())
    of ModelRole.UnviewedMessagesCount: 
      result = newQVariant(item.getUnviewedMessagesCount())

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()