import ../../../../../app_service/service/token/service as token_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokens*(self: AccessInterface): seq[token_service.TokenDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomToken*(self: AccessInterface, address: string, name: string, symbol: string, decimals: int) =
  raise newException(ValueError, "No implementation available")
        
method toggleVisible*(self: AccessInterface, symbol: string) =
  raise newException(ValueError, "No implementation available")

method removeCustomToken*(self: AccessInterface, address: string) =
  raise newException(ValueError, "No implementation available")

method getTokenDetails*(self: AccessInterface, address: string) =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    