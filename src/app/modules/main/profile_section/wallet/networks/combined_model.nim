import NimQml, Tables, strutils, strformat

import ./combined_item

type
  ModelRole* {.pure.} = enum
    Prod = UserRole + 1,
    Test
    Layer

QtObject:
  type
    CombinedModel* = ref object of QAbstractListModel
      items: seq[CombinedItem]

  proc delete(self: CombinedModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: CombinedModel) =
    self.QAbstractListModel.setup

  proc newCombinedModel*(): CombinedModel =
    new(result, delete)
    result.setup

  proc `$`*(self: CombinedModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: CombinedModel) {.signal.}

  proc getCount(self: CombinedModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount*(self: CombinedModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: CombinedModel): Table[int, string] =
    {
      ModelRole.Prod.int:"prod",
      ModelRole.Test.int:"test",
      ModelRole.Layer.int:"layer",
    }.toTable

  method data(self: CombinedModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Prod:
      result = newQVariant(item.getProd())
    of ModelRole.Test:
      result = newQVariant(item.getTest())
    of ModelRole.Layer:
      result = newQVariant(item.getLayer())

  proc setItems*(self: CombinedModel, items: seq[CombinedItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getAllNetworksSupportedPrefix*(self: CombinedModel, areTestNetworksEnabled: bool): string =
    var networkString = ""
    for item in self.items:
      networkString = networkString & item.getShortName(areTestNetworksEnabled) & ':'
    return networkString
