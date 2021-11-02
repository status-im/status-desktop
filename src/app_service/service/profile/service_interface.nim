import dto

export dto

import status/types/identity_image

export IdentityImage

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfile*(self: ServiceInterface): Dto {.base.} =
  raise newException(ValueError, "No implementation available")

method storeIdentityImage*(self: ServiceInterface, address: string, image: string, aX: int, aY: int, bX: int, bY: int): IdentityImage {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteIdentityImage*(self: ServiceInterface, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

# method getTokens*(self: ServiceInterface, chainId: int): seq[Dto] {.base.} =
#   raise newException(ValueError, "No implementation available")