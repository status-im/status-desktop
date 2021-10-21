import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isBackedUp*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonic*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method remove*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWord*(self: ServiceInterface, index: int): string {.base.} =
  raise newException(ValueError, "No implementation available")
