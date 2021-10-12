import ../../../../app_service/service/accounts/service_interface

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getGeneratedAccounts*(self: AccessInterface): 
  seq[GeneratedAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccountId*(self: AccessInterface, id: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeSelectedAccountAndLogin*(self: AccessInterface, password: string) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    