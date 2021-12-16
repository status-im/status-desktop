type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method postMessage*(self: ServiceInterface, requestType: string, message: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method ensResourceURL*(self: ServiceInterface, ens: string, url: string): (string, string, string, string, bool) =
  raise newException(ValueError, "No implementation available")
