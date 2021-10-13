import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# method getPubKey*(self: ServiceInterface): string {.base.} =
#   raise newException(ValueError, "No implementation available")

method getAppVersion*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getNodeVersion*(self: ServiceInterface): string  {.base.} =
  raise newException(ValueError, "No implementation available")
