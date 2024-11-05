import NimQml
import os

const DEFAULT_FLAG_DAPPS_ENABLED = true
const DEFAULT_FLAG_SWAP_ENABLED = true
const DEFAULT_FLAG_CONNECTOR_ENABLED* = true
const DEFAULT_FLAG_SEND_VIA_PERSONAL_CHAT_ENABLED = true
const DEFAULT_FLAG_SIMPLE_SEND_ENABLED = false

proc boolToEnv*(defaultValue: bool): string =
  return if defaultValue: "1" else: "0"

QtObject:
  type FeatureFlags* = ref object of QObject
    dappsEnabled: bool
    swapEnabled: bool
    connectorEnabled: bool
    sendViaPersonalChatEnabled: bool
    simpleSendEnabled: bool

  proc setup(self: FeatureFlags) =
    self.QObject.setup()
    self.dappsEnabled = getEnv("FLAG_DAPPS_ENABLED", boolToEnv(DEFAULT_FLAG_DAPPS_ENABLED)) != "0"
    self.swapEnabled = getEnv("FLAG_SWAP_ENABLED", boolToEnv(DEFAULT_FLAG_SWAP_ENABLED)) != "0"
    self.connectorEnabled = getEnv("FLAG_CONNECTOR_ENABLED", boolToEnv(DEFAULT_FLAG_CONNECTOR_ENABLED)) != "0"
    self.sendViaPersonalChatEnabled = getEnv("FLAG_SEND_VIA_PERSONAL_CHAT_ENABLED", boolToEnv(DEFAULT_FLAG_SEND_VIA_PERSONAL_CHAT_ENABLED)) != "0"
    self.simpleSendEnabled = getEnv("FLAG_SIMPLE_SEND_ENABLED", boolToEnv(DEFAULT_FLAG_SIMPLE_SEND_ENABLED)) != "0"

  proc delete*(self: FeatureFlags) =
    self.QObject.delete()

  proc newFeatureFlags*(): FeatureFlags =
    new(result, delete)
    result.setup()

  proc getDappsEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.dappsEnabled

  QtProperty[bool] dappsEnabled:
    read = getDappsEnabled

  proc getSwapEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.swapEnabled

  QtProperty[bool] swapEnabled:
    read = getSwapEnabled

  proc getConnectorEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.connectorEnabled

  QtProperty[bool] connectorEnabled:
    read = getConnectorEnabled

  proc getSendViaPersonalChatEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.sendViaPersonalChatEnabled

  QtProperty[bool] sendViaPersonalChatEnabled:
    read = getSendViaPersonalChatEnabled

  proc getSimpleSendEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.simpleSendEnabled

  QtProperty[bool] simpleSendEnabled:
    read = getSimpleSendEnabled
