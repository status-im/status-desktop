import dto
import dto/network_details
import dto/node_config
import dto/upstream_config

export dto
export network_details
export node_config
export upstream_config

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPubKey*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetwork*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getAppearance*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessagesFromContactsOnly*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSendUserStatus*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentUserStatus*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getIdentityImage*(self: ServiceInterface, address: string): IdentityImage {.base.} =
  raise newException(ValueError, "No implementation available")

method getDappsAddress*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setDappsAddress*(self: ServiceInterface, address: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkDetails*(self: ServiceInterface): NetworkDetails {.base.} =
  raise newException(ValueError, "No implementation available")
