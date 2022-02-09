import NimQml, Tables

import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Name
    Icon
    IsIdenticon
    Color

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete*(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

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
      ModelRole.Id.int:"itemId",
      ModelRole.Name.int:"name",
      ModelRole.Icon.int:"icon",
      ModelRole.IsIdenticon.int:"isIdenticon",
      ModelRole.Color.int:"color"
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
      result = newQVariant(item.id)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.IsIdenticon:
      result = newQVariant(item.isIdenticon)
    of ModelRole.Color:
      result = newQVariant(item.color)

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()

  proc getItemIdxById*(self: Model, id: string): int =
    var idx = 0
    for it in self.items:
      if(it.id == id):
        return idx
      idx.inc
    return -1

  proc removeItemById*(self: Model, id: string) =
    let idx = self.getItemIdxById(id)
    if idx == -1:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, idx, idx)
    self.items.delete(idx)
    self.endRemoveRows()

    self.countChanged()
