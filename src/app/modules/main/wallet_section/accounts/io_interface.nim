import json

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteAccount*(self: AccessInterface, address: string, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadAllWalletAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method filterChanged*(self: AccessInterface, chainIds: seq[int]) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateAccount*(self: AccessInterface, address: string, accountName: string, colorId: string, emoji: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccountAsJson*(self: AccessInterface, address: string): JsonNode {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateWatchAccountHiddenFromTotalBalance*(self: AccessInterface, address: string, hideFromTotalBalance: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
