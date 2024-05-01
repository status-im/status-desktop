import NimQml
import os

const DEFAULT_FLAG_DAPPS_ENABLED = false

proc boolToEnv(defaultValue: bool): string =
  return if defaultValue: "1" else: "0"

QtObject:
  type FeatureFlags* = ref object of QObject
    dappsEnabled: bool

  proc setup(self: FeatureFlags) =
    self.QObject.setup()
    self.dappsEnabled = getEnv("FLAG_DAPPS_ENABLED", boolToEnv(DEFAULT_FLAG_DAPPS_ENABLED)) != "0"

  proc delete*(self: FeatureFlags) =
    self.QObject.delete()

  proc newFeatureFlags*(): FeatureFlags =
    new(result, delete)
    result.setup()

  proc getDappsEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.dappsEnabled

  QtProperty[bool] dappsEnabled:
    read = getDappsEnabled
