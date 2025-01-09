import app_service/service/ramp/dto

type AccessInterface* {.pure, inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchProviders*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchProviderUrl*(
    self: AccessInterface,
    uuid: string,
    providerID: string,
    parameters: CryptoRampParametersDto,
) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateRampProviders*(
    self: AccessInterface, cryptoServices: seq[CryptoRampDto]
) {.base.} =
  raise newException(ValueError, "No implementation available")

method onRampProviderUrlReady*(
    self: AccessInterface, uuid: string, url: string
) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
