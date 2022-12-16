import NimQml, Tables, strutils, strformat

import ./collectible_trait_item

type
  ModelRole {.pure.} = enum
    TraitType = UserRole + 1,
    Value
    DisplayType
    MaxValue

QtObject:
  type
    TraitModel* = ref object of QAbstractListModel
      items: seq[CollectibleTrait]

  proc delete(self: TraitModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: TraitModel) =
    self.QAbstractListModel.setup

  proc newTraitModel*(): TraitModel =
    new(result, delete)
    result.setup

  proc `$`*(self: TraitModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: TraitModel) {.signal.}

  proc getCount(self: TraitModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TraitModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: TraitModel): Table[int, string] =
    {
      ModelRole.TraitType.int:"traitType",
      ModelRole.Value.int:"value",
      ModelRole.DisplayType.int:"displayType",
      ModelRole.MaxValue.int:"maxValue",
    }.toTable

  method data(self: TraitModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.TraitType:
      result = newQVariant(item.getTraitType())
    of ModelRole.Value:
      result = newQVariant(item.getValue())
    of ModelRole.DisplayType:
      result = newQVariant(item.getDisplayType())
    of ModelRole.MaxValue:
      result = newQVariant(item.getMaxValue())

  proc setItems*(self: TraitModel, items: seq[CollectibleTrait]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()
