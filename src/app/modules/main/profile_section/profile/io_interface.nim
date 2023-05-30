import NimQml

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method storeIdentityImage*(self: AccessInterface, imageUrl: string, aX: int, aY: int, bX: int, bY: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteIdentityImage*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getBio*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBio*(self: AccessInterface, bio: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBioChanged*(self: AccessInterface, bio: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: AccessInterface, displayName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveSocialLinks*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
