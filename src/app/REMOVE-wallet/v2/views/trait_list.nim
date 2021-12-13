import NimQml, Tables
from status/wallet2 import OpenseaTrait

type
  TraitRoles {.pure.} = enum
    TraitType = UserRole + 1,
    Value = UserRole + 2,
    DisplayType = UserRole + 3,
    MaxValue = UserRole + 4


QtObject:
  type TraitsList* = ref object of QAbstractListModel
    traits*: seq[OpenseaTrait]

  proc setup(self: TraitsList) = self.QAbstractListModel.setup

  proc delete(self: TraitsList) =
    self.traits = @[]
    self.QAbstractListModel.delete

  proc newTraitsList*(): TraitsList =
    new(result, delete)
    result.traits = @[]
    result.setup
  
  method rowCount*(self: TraitsList, index: QModelIndex = nil): int =
    return self.traits.len

  method data(self: TraitsList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.traits.len:
      return
    
    let trait = self.traits[index.row]
    let traitRole = role.TraitRoles
    case traitRole:
    of TraitRoles.TraitType: result = newQVariant(trait.traitType)
    of TraitRoles.Value: result = newQVariant(trait.value)
    of TraitRoles.DisplayType: result = newQVariant(trait.displayType)
    of TraitRoles.MaxValue: result = newQVariant(trait.maxValue)

  method roleNames(self: TraitsList): Table[int, string] =
    { TraitRoles.TraitType.int:"traitType",
    TraitRoles.Value.int:"value",
    TraitRoles.DisplayType.int:"displayType",
    TraitRoles.MaxValue.int:"maxValue"}.toTable
