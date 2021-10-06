type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")


type 
  DelegateInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class inherited by objects used in this module.

method didLoad*(self: DelegateInterface) {.base.} =
  raise newException(ValueError, "No implementation available")