import ../../../../../app_service/service/network/service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setDappsAddress*(self: AccessInterface, newDappAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDappAddressChanged*(self: AccessInterface, newDappAddress: string) {.base.}  =
  raise newException(ValueError, "No implementation available")

method disconnect*(self: AccessInterface, dappName: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method postMessage*(self: AccessInterface, payloadMethod: string, requestType: string, message: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method ensResourceURL*(self: AccessInterface, ens: string, url: string): (string, string, string, string, bool) =
  raise newException(ValueError, "No implementation available")

method onPostMessage*(self: AccessInterface, payloadMethod: string, result: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateNetwork*(self: AccessInterface, network: NetworkDto) {.base.} =
  raise newException(ValueError, "No implementation available")