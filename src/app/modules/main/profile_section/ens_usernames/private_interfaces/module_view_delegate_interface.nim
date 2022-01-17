method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method checkEnsUsernameAvailability*(self: AccessInterface, desiredEnsUsername: string, statusDomain: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method numOfPendingEnsUsernames*(self: AccessInterface): int {.base.} =
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

method releaseEnsEstimate*(self: AccessInterface, ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method release*(self: AccessInterface, ensUsername: string, address: string, gas: string, gasPrice: string, 
  password: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method connectOwnedUsername*(self: AccessInterface, ensUsername: string, isStatus: bool) {.base.} =
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

method getFiatValue*(self: AccessInterface, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method getGasEthValue*(self: AccessInterface, gweiValue: string, gasLimit: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusToken*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setPrefferedEnsUsername*(self: AccessInterface, ensUsername: string) {.base.} =
  raise newException(ValueError, "No implementation available")