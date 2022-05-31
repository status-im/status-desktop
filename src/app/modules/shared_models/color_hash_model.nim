import NimQml, Tables, json

import color_hash_item

type
  ColorHashSegment* = tuple[len, colorIdx: int]

type
  ModelRole {.pure.} = enum
    SegmentLength = UserRole + 1
    ColorId

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

  proc setItems*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc toJson*(self: Model): string {.slot.} =
    let json = newJArray()
    for item in self.items:
      json.add(%* {"segmentLength": item.segmentLength(), "colorId": item.colorId()})
    return $json

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.SegmentLength:
        result = newQVariant(item.segmentLength)
      of ModelRole.ColorId:
        result = newQVariant(item.colorId)

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.SegmentLength.int:"segmentLength",
      ModelRole.ColorId.int:"colorId",
    }.toTable
