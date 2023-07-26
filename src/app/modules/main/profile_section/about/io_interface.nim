type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getAppVersion*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getNodeVersion*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusGoVersion*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method versionFetched*(self: AccessInterface, available: bool, version: string, url: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkForUpdates*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
