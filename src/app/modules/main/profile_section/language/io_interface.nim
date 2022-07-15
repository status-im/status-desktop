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

method changeLocale*(self: AccessInterface, locale: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setIsDDMMYYDateFormat*(self: AccessInterface, isDDMMYYDateFormat: bool) {.slot.} =
  raise newException(ValueError, "No implementation available")

method setIs24hTimeFormat*(self: AccessInterface, is24hTimeFormat: bool) {.slot.} =
  raise newException(ValueError, "No implementation available")

method onCurrentLocaleChanged*(self: AccessInterface, locale: string) {.base.} =
  raise newException(ValueError, "No implementation available")


# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
