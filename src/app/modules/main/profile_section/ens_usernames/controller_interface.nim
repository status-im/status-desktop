import ../../../../../app_service/service/settings/dto/settings as settings_dto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkEnsUsernameAvailability*(self: AccessInterface, desiredEnsUsername: string, statusDomain: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyPendingEnsUsernames*(self: AccessInterface): seq[string] {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllMyEnsUsernames*(self: AccessInterface, includePendingEnsUsernames: bool): seq[string] {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchDetailsForEnsUsername*(self: AccessInterface, ensUsername: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchGasPrice*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPubKeyGasEstimate*(self: AccessInterface, ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setPubKey*(self: AccessInterface, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkDetails*(self: AccessInterface): Network {.base.} =
  raise newException(ValueError, "No implementation available")

method getSigningPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method saveNewEnsUsername*(self: AccessInterface, ensUsername: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPreferredEnsUsername*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method releaseEnsEstimate*(self: AccessInterface, ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method release*(self: AccessInterface, ensUsername: string, address: string, gas: string, gasPrice: string,
  password: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setPreferredName*(self: AccessInterface, preferredName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getEnsRegisteredAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method registerEnsGasEstimate*(self: AccessInterface, ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method registerEns*(self: AccessInterface, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getSNTBalance*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletDefaultAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentCurrency*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getPrice*(self: AccessInterface, crypto: string, fiat: string): float64 {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusToken*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")
