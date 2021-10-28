type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomNetwork*(self: ServiceInterface, name: string, endpoint: string, networkId: int, networkType: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changeNetwork*(self: ServiceInterface, network: string) {.base.} =
  raise newException(ValueError, "No implementation available")
