type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomToken*(self: AccessInterface, address: string, name: string, symbol: string, decimals: int)  {.base.} =
  raise newException(ValueError, "No implementation available")
        
method toggleVisible*(self: AccessInterface, symbol: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeCustomToken*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshTokens*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
