import ../../../../app_service/service/accounts/service_interface

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
    
method getOpenedAccounts*(self: AccessInterface): seq[AccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccountKeyUid*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method login*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")