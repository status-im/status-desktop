type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method moveToAppState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method startUpUIRaised*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method userLoggedIn*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitLogOut*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loginDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onboardingDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")



# This way (using concepts) is used only for the modules managed by AppController
type
  DelegateInterface* = concept c
    c.startupDidLoad()
    c.userLoggedIn()
