import app_service/service/network/network_item

type
  NetworksDataSource* = tuple[
    getFlatNetworksList: proc(): var seq[NetworkItem],
    getRpcProvidersList: proc(): var seq[RpcProviderItem]
  ]

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleTestNetworksEnabled*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setNetworksState*(self: AccessInterface, chainIds: seq[int], enable: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshNetworks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setNetworkActive*(self: AccessInterface, chainId: int, active: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateNetworkEndPointValues*(self: AccessInterface, chainId: int, testNetwork: bool, newMainRpcInput, newFailoverRpcUrl: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchChainIdForUrl*(self: AccessInterface, url: string, isMainUrl: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method chainIdFetchedForUrl*(self: AccessInterface, url: string, chainId: int, success: bool, isMainUrl: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworksDataSource*(self: AccessInterface): NetworksDataSource {.base.} =
  raise newException(ValueError, "No implementation available")
