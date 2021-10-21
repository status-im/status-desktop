import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokens*(self: ServiceInterface): seq[TokenDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomToken*(self: ServiceInterface, address: string, name: string, symbol: string, decimals: int) =
  raise newException(ValueError, "No implementation available")
        
method toggleVisible*(self: ServiceInterface, symbol: string) =
  raise newException(ValueError, "No implementation available")

method removeCustomToken*(self: ServiceInterface, address: string) =
  raise newException(ValueError, "No implementation available")