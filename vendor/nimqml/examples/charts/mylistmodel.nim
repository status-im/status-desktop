import NimQml, Tables, random

type
  Point = object
    x: int
    y: int

QtObject:
  type
    MyListModel* = ref object of QAbstractTableModel
      points*: seq[Point]
      maxX: int
      maxY: int

  proc delete(self: MyListModel) =
    self.QAbstractTableModel.delete

  proc setup(self: MyListModel) =
    self.QAbstractTableModel.setup

  method rowCount(self: MyListModel, index: QModelIndex = nil): int =
    return self.points.len

  method columnCount(self: MyListModel, index: QModelIndex = nil): int =
    return 2

  method data(self: MyListModel, index: QModelIndex, role: int): QVariant =
    result = nil
    if not index.isValid or index.row < 0 or index.row >= self.rowCount() or index.column < 0 or index.column >= self.columnCount():
      return
    if role == 0:
      let point = self.points[index.row]
      if index.column == 0:
        return newQVariant(point.x)
      elif index.column == 1:
        return newQVariant(point.y)

  proc getMaxY(self: MyListModel): int {.slot.} =
    return self.maxY

  proc maxYChanged(self: MyListModel, value: int) {.signal.}

  QtProperty[int] maxY:
    read = getMaxY
    notify = maxYChanged

  proc getMaxX(self: MyListModel): int {.slot.} =
    return self.maxX

  proc maxXChanged(self: MyListModel, value: int) {.signal.}

  QtProperty[int] maxX:
    read = getMaxX
    notify = maxXChanged

  proc addRandomPoint(self: MyListModel) {.slot.} =
    let pos = self.points.len
    self.beginInsertRows(newQModelIndex(), pos, pos)
    let x = self.maxX + 1
    let y = random(50)
    if x > self.maxX:
      self.maxX = x
      self.maxXChanged(x)
    if y > self.maxY:
      self.maxY = y
      self.maxYChanged(y)
    self.points.add(Point(x: x, y: y))
    self.endInsertRows()

  proc newMyListModel*(): MyListModel =
    new(result, delete)
    result.setup
    result.points = @[]
    result.maxX = 0
    result.maxY = 50
    result.addRandomPoint()
