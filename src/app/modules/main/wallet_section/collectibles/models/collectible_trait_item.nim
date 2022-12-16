type
  CollectibleTrait* = object
    traitType, value, displayType, maxValue: string

proc getTraitType*(self: CollectibleTrait): string =
  return self.traitType

proc getValue*(self: CollectibleTrait): string =
  return self.value

proc getDisplayType*(self: CollectibleTrait): string =
  return self.displayType

proc getMaxValue*(self: CollectibleTrait): string =
  return self.maxValue

proc initTrait*(
  traitType, value, displayType, maxValue: string
): CollectibleTrait =
  result.traitType = traitType
  result.value = value
  result.displayType = displayType
  result.maxValue = maxValue