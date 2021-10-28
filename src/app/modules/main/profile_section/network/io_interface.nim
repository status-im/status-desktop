import ../../../../../app_service/service/settings/dto/network_details

export NetworkDetails

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkDetails*(self: AccessInterface): NetworkDetails {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworks*(self: AccessInterface): seq[NetworkDetails] {.base.} =
  raise newException(ValueError, "No implementation available")

method changeNetwork*(self: AccessInterface, network: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomNetwork*(self: AccessInterface, name: string, endpoint: string, networkId: int, networkType: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
