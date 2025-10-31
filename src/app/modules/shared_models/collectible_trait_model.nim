import nimqml, tables, strutils, stew/shims/strformat

import backend/collectibles as backend
import ../shared/model_sync

type
  ModelRole {.pure.} = enum
    TraitType = UserRole + 1,
    Value
    DisplayType
    MaxValue

QtObject:
  type
    TraitModel* = ref object of QAbstractListModel
      items: seq[backend.CollectibleTrait]

  proc delete(self: TraitModel)
  proc setup(self: TraitModel)
  proc newTraitModel*(): TraitModel =
    new(result, delete)
    result.setup

  proc `$`*(self: TraitModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  proc countChanged(self: TraitModel) {.signal.}

  proc getCount*(self: TraitModel): int {.slot.} =
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
      result = newQVariant(item.trait_type)
    of ModelRole.Value:
      result = newQVariant(item.value)
    of ModelRole.DisplayType:
      result = newQVariant(item.display_type)
    of ModelRole.MaxValue:
      result = newQVariant(item.max_value)

  proc setItems*(self: TraitModel, items: seq[CollectibleTrait]) =
    self.setItemsWithSync(
      self.items,
      items,
      getId = proc(item: CollectibleTrait): string =
        # Unique ID: trait_type (traits are unique by type for a collectible)
        item.trait_type,
      getRoles = proc(old, new: CollectibleTrait): seq[int] =
        var roles: seq[int]
        if old.value != new.value:
          roles.add(ModelRole.Value.int)
        if old.display_type != new.display_type:
          roles.add(ModelRole.DisplayType.int)
        if old.max_value != new.max_value:
          roles.add(ModelRole.MaxValue.int)
        return roles,
      useBulkOps = true,
      countChanged = proc() = self.countChanged()
    )

  proc delete(self: TraitModel) =
    self.QAbstractListModel.delete

  proc setup(self: TraitModel) =
    self.QAbstractListModel.setup

