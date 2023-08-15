import NimQml
import io_interface
import model
from ../../../../../app_service/service/ens/utils import ENS_REGISTRY

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      etherscanLink: string
      signingPhrase: string

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.delegate = delegate

  proc load*(self: View, link: string, signingPhrase: string) =
    self.etherscanLink = link
    self.signingPhrase = signingPhrase
    self.delegate.viewDidLoad()

  proc model*(self: View): Model =
    return self.model

  proc modelChanged*(self: View) {.signal.}
  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant
  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc chainIdChanged*(self: View) {.signal.}
  proc chainId(self: View): int {.slot.} =
    return self.delegate.getChainIdForEns()
  QtProperty[int] chainId:
    read = chainId
    notify = chainIdChanged

  proc emitChainIdChanged*(self: View) =
    self.chainIdChanged()

  proc getEnsRegistry(self: View): string {.slot.} =
    return ENS_REGISTRY

  proc usernameAvailabilityChecked(self: View, availabilityStatus: string) {.signal.}
  proc sendUsernameAvailabilityCheckedSignal*(self: View, availabilityStatus: string) =
    self.usernameAvailabilityChecked(availabilityStatus)

  proc checkEnsUsernameAvailability*(self: View, desiredEnsUsername: string, statusDomain: bool) {.slot.} =
    self.delegate.checkEnsUsernameAvailability(desiredEnsUsername, statusDomain)

  proc numOfPendingEnsUsernames*(self: View): int {.slot.} =
    return self.delegate.numOfPendingEnsUsernames()

  proc loading(self: View, isLoading: bool) {.signal.}
  proc detailsObtained(self: View, chainId: int, ensName: string, address: string, pubkey: string, isStatus: bool, expirationTime: int) {.signal.}

  proc fetchDetailsForEnsUsername*(self: View, chainId: int, ensUsername: string) {.slot.} =
    self.loading(true)
    self.delegate.fetchDetailsForEnsUsername(chainId, ensUsername)

  proc processObtainedEnsUsermesDetails*(self: View, chainId: int, ensUsername: string, address: string, pubkey: string, isStatus: bool,
    expirationTime: int) =
    self.loading(false)
    self.detailsObtained(chainId, ensUsername, address, pubkey, isStatus, expirationTime)

  proc transactionWasSent(self: View, chainId: int, txHash: string, error: string) {.signal.}
  proc emitTransactionWasSentSignal*(self: View, chainId: int, txHash: string, error: string) =
    self.transactionWasSent(chainId, txHash, error)

  proc setPubKeyGasEstimate*(self: View, chainId: int, ensUsername: string, address: string): int {.slot.} =
    return self.delegate.setPubKeyGasEstimate(chainId, ensUsername, address)

  proc authenticateAndSetPubKey*(self: View, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.slot.} =
    self.delegate.authenticateAndSetPubKey(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)

  proc getEtherscanLink*(self: View): string {.slot.} =
    return self.etherscanLink

  proc getSigningPhrase*(self: View): string {.slot.} =
    return self.signingPhrase

  proc usernameConfirmed(self: View, username: string) {.signal.}
  proc emitUsernameConfirmedSignal*(self: View, ensUsername: string) =
    self.usernameConfirmed(ensUsername)

  proc transactionCompleted(self: View, success: bool, txHash: string, username: string, trxType: string) {.signal.}
  proc emitTransactionCompletedSignal*(self: View, success: bool, txHash: string, username: string, trxType: string) =
    self.transactionCompleted(success, txHash, username, trxType)

  proc removeEnsUsername*(self: View, chainId: int, ensUsername: string): bool {.slot.} =
    return self.delegate.removeEnsUsername(chainId, ensUsername)

  proc releaseEnsEstimate*(self: View, chainId: int, ensUsername: string, address: string): int {.slot.} =
    return self.delegate.releaseEnsEstimate(chainId, ensUsername, address)

  proc authenticateAndReleaseEns*(self: View, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.slot.} =
    self.delegate.authenticateAndReleaseEns(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)

  proc connectOwnedUsername*(self: View, ensUsername: string, isStatus: bool) {.slot.} =
    self.delegate.connectOwnedUsername(ensUsername, isStatus)

  proc getEnsRegisteredAddress*(self: View): string {.slot.} =
    return self.delegate.getEnsRegisteredAddress()

  proc registerEnsGasEstimate*(self: View, chainId: int, ensUsername: string, address: string): int {.slot.} =
    return self.delegate.registerEnsGasEstimate(chainId, ensUsername, address)

  proc authenticateAndRegisterEns*(self: View, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.slot.} =
    self.delegate.authenticateAndRegisterEns(chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)

  proc getSNTBalance*(self: View): string {.slot.} =
    return self.delegate.getSNTBalance()

  proc getWalletDefaultAddress*(self: View): string {.slot.} =
    return self.delegate.getWalletDefaultAddress()

  proc getCurrentCurrency*(self: View): string {.slot.} =
    return self.delegate.getCurrentCurrency()

  proc getFiatValue*(self: View, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string {.slot.} =
    return self.delegate.getFiatValue(cryptoBalance, cryptoSymbol, fiatSymbol)

  proc getCryptoValue*(self: View, fiatAmount: string, cryptoSymbol: string, fiatSymbol: string): string {.slot.} =
    return self.delegate.getCryptoValue(fiatAmount, cryptoSymbol, fiatSymbol)

  proc getGasEthValue*(self: View, gweiValue: string, gasLimit: string): string {.slot.} =
    return self.delegate.getGasEthValue(gweiValue, gasLimit)

  proc getStatusToken*(self: View): string {.slot.} =
    return self.delegate.getStatusToken()

  proc getChainIdForEns*(self: View): int {.slot.} =
    return self.delegate.getChainIdForEns()

  proc setPrefferedEnsUsername*(self: View, ensUsername: string) {.slot.} =
    self.delegate.setPrefferedEnsUsername(ensUsername)
