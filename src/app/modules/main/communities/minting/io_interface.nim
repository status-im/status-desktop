import ../../../../../app_service/service/community_tokens/dto/community_token

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method mintCollectible*(self: AccessInterface, communityId: string, address: string, name: string, symbol: string, description: string, supply: int, infiniteSupply: bool, transferable: bool,
                      selfDestruct: bool, chainId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")
