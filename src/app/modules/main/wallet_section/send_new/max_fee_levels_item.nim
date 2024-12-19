import NimQml

QtObject:
  type MaxFeeLevelsItem* = ref object of QObject
    low: string
    medium: string
    high: string

  proc setup*(self: MaxFeeLevelsItem,
    low: string,
    medium: string,
    high: string
  ) =
    self.QObject.setup
    self.low = low
    self.medium = medium
    self.high = high

  proc delete*(self: MaxFeeLevelsItem) =
      self.QObject.delete

  proc newMaxFeeLevelsItem*(
    low: string,
    medium: string,
    high: string
    ): MaxFeeLevelsItem =
      new(result, delete)
      result.setup(low, medium, high)

  proc `$`*(self: MaxFeeLevelsItem): string =
    result = "MaxFeeLevelsItem("
    result = result & "\low: " & $self.low
    result = result & "\nmedium " & $self.medium
    result = result & "\nhigh: " & $self.high
    result = result & ")"

  proc getLow*(self: MaxFeeLevelsItem): string {.slot.} =
    return self.low
  QtProperty[string] low:
    read = getLow

  proc getMedium*(self: MaxFeeLevelsItem): string {.slot.} =
    return self.medium
  QtProperty[string] medium:
    read = getMedium

  proc getHigh*(self: MaxFeeLevelsItem): string {.slot.} =
    return self.high
  QtProperty[string] high:
    read = getHigh
