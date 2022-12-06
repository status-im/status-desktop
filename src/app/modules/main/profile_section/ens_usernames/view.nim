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
  proc detailsObtained(self: View, ensName: string, address: string, pubkey: string, isStatus: bool, expirationTime: int) {.signal.}

  proc fetchDetailsForEnsUsername*(self: View, ensUsername: string) {.slot.} =
    self.loading(true)
    self.delegate.fetchDetailsForEnsUsername(ensUsername)

  proc setDetailsForEnsUsername*(self: View, ensUsername: string, address: string, pubkey: string, isStatus: bool,
    expirationTime: int) =
    self.loading(false)
    self.detailsObtained(ensUsername, address, pubkey, isStatus, expirationTime)

  proc transactionWasSent(self: View, txResult: string) {.signal.}
  proc emitTransactionWasSentSignal*(self: View, txResult: string) =
    self.transactionWasSent(txResult)

  proc setPubKeyGasEstimate*(self: View, ensUsername: string, address: string): int {.slot.} =
    return self.delegate.setPubKeyGasEstimate(ensUsername, address)

  proc authenticateAndSetPubKey*(self: View, ensUsername: string, address: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.slot.} =
    self.delegate.authenticateAndSetPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)

  proc getEtherscanLink*(self: View): string {.slot.} =
    return self.etherscanLink

  proc getSigningPhrase*(self: View): string {.slot.} =
    return self.signingPhrase

  proc usernameConfirmed(self: View, username: string) {.signal.}
  proc emitUsernameConfirmedSignal*(self: View, ensUsername: string) =
    self.usernameConfirmed(ensUsername)

  proc transactionCompleted(self: View, success: bool, txHash: string, username: string, trxType: string,
    revertReason: string) {.signal.}
  proc emitTransactionCompletedSignal*(self: View, success: bool, txHash: string, username: string, trxType: string,
    revertReason: string) =
    self.transactionCompleted(success, txHash, username, trxType, revertReason)

  proc removeEnsUsername*(self: View, ensUsername: string): bool {.slot.} =
    return self.delegate.removeEnsUsername(ensUsername)

  proc releaseEnsEstimate*(self: View, ensUsername: string, address: string): int {.slot.} =
    return self.delegate.releaseEnsEstimate(ensUsername, address)

  proc authenticateAndReleaseEns*(self: View, ensUsername: string, address: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.slot.} =
    self.delegate.authenticateAndReleaseEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)

  proc connectOwnedUsername*(self: View, ensUsername: string, isStatus: bool) {.slot.} =
    self.delegate.connectOwnedUsername(ensUsername, isStatus)

  proc getEnsRegisteredAddress*(self: View): string {.slot.} =
    return self.delegate.getEnsRegisteredAddress()

  proc registerEnsGasEstimate*(self: View, ensUsername: string, address: string): int {.slot.} =
    return self.delegate.registerEnsGasEstimate(ensUsername, address)

  proc authenticateAndRegisterEns*(self: View, ensUsername: string, address: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) {.slot.} =
    self.delegate.authenticateAndRegisterEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, eip1559Enabled)

  proc getSNTBalance*(self: View): string {.slot.} =
    return self.delegate.getSNTBalance()

  proc getWalletDefaultAddress*(self: View): string {.slot.} =
    return self.delegate.getWalletDefaultAddress()

  proc getCurrentCurrency*(self: View): string {.slot.} =
    return self.delegate.getCurrentCurrency()

  proc getFiatValue*(self: View, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string {.slot.} =
    return self.delegate.getFiatValue(cryptoBalance, cryptoSymbol, fiatSymbol)

  proc getGasEthValue*(self: View, gweiValue: string, gasLimit: string): string {.slot.} =
    return self.delegate.getGasEthValue(gweiValue, gasLimit)

  proc getStatusToken*(self: View): string {.slot.} =
    return self.delegate.getStatusToken()

  proc getChainIdForEns*(self: View): int {.slot.} =
    return self.delegate.getChainIdForEns()

  proc setPrefferedEnsUsername*(self: View, ensUsername: string) {.slot.} =
    self.delegate.setPrefferedEnsUsername(ensUsername)
