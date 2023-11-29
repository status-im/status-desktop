import NimQml
from app_service/service/keycard/service import KeycardEvent

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method ensUsernameAvailabilityChecked*(self: AccessInterface, availabilityStatus: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDetailsForEnsUsername*(self: AccessInterface, chainId: int, ensUsername: string, address: string, pubkey: string,
  isStatus: bool, expirationTime: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method ensTransactionConfirmed*(self: AccessInterface, trxType: string, ensUsername: string, transactionHash: string)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method ensTransactionReverted*(self: AccessInterface, trxType: string, ensUsername: string, transactionHash: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkEnsUsernameAvailability*(self: AccessInterface, desiredEnsUsername: string, statusDomain: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method numOfPendingEnsUsernames*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchDetailsForEnsUsername*(self: AccessInterface, chainId: int, ensUsername: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPubKeyGasEstimate*(self: AccessInterface, chainId: int,  ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateAndSetPubKey*(self: AccessInterface, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeEnsUsername*(self: AccessInterface, chainId: int, ensUsername: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method releaseEnsEstimate*(self: AccessInterface, chainId: int, ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateAndReleaseEns*(self: AccessInterface, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method connectOwnedUsername*(self: AccessInterface, ensUsername: string, isStatus: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getEnsRegisteredAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method registerEnsGasEstimate*(self: AccessInterface, chainId: int, ensUsername: string, address: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateAndRegisterEns*(self: AccessInterface, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.base.} =
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

method getCryptoValue*(self: AccessInterface, fiatAmount: string, cryptoSymbol: string, fiatSymbol: string): string
  {.base.} =
  raise newException(ValueError, "No implementation available")

method getGasEthValue*(self: AccessInterface, gweiValue: string, gasLimit: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getStatusToken*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChainIdForEns*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setPrefferedEnsUsername*(self: AccessInterface, ensUsername: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeypairAuthenticated*(self: AccessInterface, password: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTransactionSigned*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")