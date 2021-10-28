import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getActiveMailserver*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getAutomaticSelection*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method pinMailserver*(self: ServiceInterface, id: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableAutomaticSelection*(self: ServiceInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveMailserver*(self: ServiceInterface, name: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")
