import NimQml
import os, macros, strutils

proc boolToEnv*(defaultValue: bool): string =
  return if defaultValue: "1" else: "0"

# The `featureFlag` macro defines a feature flag based on an environment variable.
# If the `buildFlag` variable is true, the feature flag is determined at compile time.
# Otherwise, it is determined at runtime.
macro featureFlag(name: string, defaultValue: bool, buildFlag: static bool = false): untyped =
  let flagName = newIdentNode(name.strVal)
  if `buildFlag`:
    return quote do:
      const `flagName`* = static(getEnv("FLAG_" & `name`.toUpper, boolToEnv(`defaultValue`)) != "0")
  else:
    return quote do:
      let `flagName`* = getEnv("FLAG_" & `name`.toUpper, boolToEnv(`defaultValue`)) != "0"

const DEFAULT_FLAG_SWAP_ENABLED  = true
const DEFAULT_FLAG_SEND_VIA_PERSONAL_CHAT_ENABLED  = true
const DEFAULT_FLAG_PAYMENT_REQUEST_ENABLED = true
const DEFAULT_FLAG_SIMPLE_SEND_ENABLED = true
const DEFAULT_FLAG_MARKET_ENABLED = true
const DEFAULT_FLAG_SHELL_ENABLED = false

# Compile time feature flags
const DEFAULT_FLAG_DAPPS_ENABLED  = true
const DEFAULT_FLAG_CONNECTOR_ENABLED  = true
const DEFAULT_FLAG_KEYCARD_ENABLED = true
const DEFAULT_FLAG_THREADPOOL_ENABLED = true
const DEFAULT_FLAG_SINGLE_STATUS_INSTANCE_ENABLED = true

# Public feature flags
featureFlag("SWAP_ENABLED",                   DEFAULT_FLAG_SWAP_ENABLED)
featureFlag("SEND_VIA_PERSONAL_CHAT_ENABLED", DEFAULT_FLAG_SEND_VIA_PERSONAL_CHAT_ENABLED)
featureFlag("PAYMENT_REQUEST_ENABLED",        DEFAULT_FLAG_PAYMENT_REQUEST_ENABLED)
featureFlag("SIMPLE_SEND_ENABLED",            DEFAULT_FLAG_SIMPLE_SEND_ENABLED)
featureFlag("MARKET_ENABLED",                 DEFAULT_FLAG_MARKET_ENABLED)
featureFlag("SHELL_ENABLED",                  DEFAULT_FLAG_SHELL_ENABLED)

featureFlag("DAPPS_ENABLED",                  DEFAULT_FLAG_DAPPS_ENABLED, true)
featureFlag("CONNECTOR_ENABLED",              DEFAULT_FLAG_CONNECTOR_ENABLED, true)
featureFlag("KEYCARD_ENABLED",                DEFAULT_FLAG_KEYCARD_ENABLED, true)
featureFlag("THREADPOOL_ENABLED",             DEFAULT_FLAG_THREADPOOL_ENABLED, true)
featureFlag("SINGLE_STATUS_INSTANCE_ENABLED", DEFAULT_FLAG_SINGLE_STATUS_INSTANCE_ENABLED, true)
# The `featureGuard` macro conditionally replaces the guarded code
# There are two main usages:
# 1. With a statement list:
#    featureGuard(FEATURE_FLAG):
#      echo "Feature is enabled"
#    else:
#      echo "Feature is disabled"
# 2. As a pragma:
#    proc myProc(): void {.featureGuard(FEATURE_FLAG).} = echo "Feature is enabled"
macro featureGuard*(flag: static bool, n: varargs[untyped]): untyped =
  if n.len == 2 and n[1].kind == nnkElse:
    if flag:
      result = n[0]
    else:
      result = n[1][0]
  else:
    if not flag:
      if n[0].kind == nnkStmtList:
        result = newStmtList()
      elif n[0].kind == nnkProcDef:
        result = n[0]
        result[6] = newStmtList(
          newCall(bindSym"echo", newLit("Warning! Calling a disabled feature")),
          newTree(nnkDiscardStmt, newEmptyNode())
        ) # Replace body with `discard`
      else:
        result = newStmtList()
    else:
      result = n[0]

QtObject:
  type FeatureFlags* = ref object of QObject
    dappsEnabled: bool
    swapEnabled: bool
    connectorEnabled: bool
    sendViaPersonalChatEnabled: bool
    paymentRequestEnabled: bool
    simpleSendEnabled: bool
    keycardEnabled: bool
    marketEnabled: bool
    shellEnabled: bool

  proc setup(self: FeatureFlags) =
    self.QObject.setup()
    self.dappsEnabled = DAPPS_ENABLED
    self.swapEnabled = SWAP_ENABLED
    self.connectorEnabled = CONNECTOR_ENABLED
    self.sendViaPersonalChatEnabled = SEND_VIA_PERSONAL_CHAT_ENABLED
    self.paymentRequestEnabled = PAYMENT_REQUEST_ENABLED
    self.simpleSendEnabled = SIMPLE_SEND_ENABLED
    self.keycardEnabled = KEYCARD_ENABLED
    self.marketEnabled = MARKET_ENABLED
    self.shellEnabled = SHELL_ENABLED

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

  proc getPaymentRequestEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.paymentRequestEnabled

  QtProperty[bool] paymentRequestEnabled:
    read = getPaymentRequestEnabled

  proc getSimpleSendEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.simpleSendEnabled

  QtProperty[bool] simpleSendEnabled:
    read = getSimpleSendEnabled

  QtProperty[bool] keycardEnabled:
    read = getKeycardEnabled

  proc getKeycardEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.keycardEnabled

  QtProperty[bool] marketEnabled:
    read = getMarketEnabled

  proc getMarketEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.marketEnabled

  QtProperty[bool] shellEnabled:
    read = getShellEnabled

  proc getShellEnabled*(self: FeatureFlags): bool {.slot.} =
    return self.shellEnabled
