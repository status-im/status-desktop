import ../../../../../app_service/service/saved_address/service_interface as saved_address_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSavedAddresses*(self: AccessInterface): seq[saved_address_service.SavedAddressDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method addSavedAddresses*(self: AccessInterface, name, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteSavedAddresses*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    
