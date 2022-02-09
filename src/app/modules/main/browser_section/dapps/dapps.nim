import NimQml, Tables, strutils, strformat

type
  ModelRole {.pure.} = enum
    Name = UserRole + 1

QtObject:
  type
    DappsModel* = ref object of QAbstractListModel
      items: seq[string]

  proc delete(self: DappsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: DappsModel) =
    self.QAbstractListModel.setup

  proc newDappsModel*(): DappsModel =
    new(result, delete)
    result.setup

  proc `$`*(self: DappsModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc modelChanged(self: DappsModel) {.signal.}

  proc getCount(self: DappsModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: DappsModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: DappsModel): Table[int, string] =
    {
      ModelRole.Name.int:"name"
    }.toTable

  method data(self: DappsModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    result = newQVariant(self.items[index.row])

  proc addItem*(self: DappsModel, item: string) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    for i in self.items:
      if i == item:
        return

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.modelChanged()

  proc clear*(self: DappsModel) =
    self.beginResetModel()
    self.items = @[]
    self.endResetModel()
