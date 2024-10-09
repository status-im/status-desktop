import NimQml
import io_interface
import model
from app_service/service/ens/utils import ENS_REGISTRY

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      etherscanLink: string

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

  proc load*(self: View, link: string) =
    self.etherscanLink = link
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
  proc detailsObtained(self: View, chainId: int, ensName: string, address: string, pubkey: string, isStatus: bool, expirationTime: int) {.signal.}

  proc fetchDetailsForEnsUsername*(self: View, chainId: int, ensUsername: string) {.slot.} =
    self.loading(true)
    self.delegate.fetchDetailsForEnsUsername(chainId, ensUsername)

  proc processObtainedEnsUsermesDetails*(self: View, chainId: int, ensUsername: string, address: string, pubkey: string, isStatus: bool,
    expirationTime: int) =
    self.loading(false)
    self.detailsObtained(chainId, ensUsername, address, pubkey, isStatus, expirationTime)

  proc transactionWasSent(self: View, trxType: string, chainId: int, txHash: string, username: string, error: string) {.signal.}
  proc emitTransactionWasSentSignal*(self: View, trxType: string, chainId: int, txHash: string, username: string, error: string) =
    self.transactionWasSent(trxType, chainId, txHash, username, error)

  proc getEtherscanLink*(self: View): string {.slot.} =
    return self.etherscanLink

  proc usernameConfirmed(self: View, username: string) {.signal.}
  proc emitUsernameConfirmedSignal*(self: View, ensUsername: string) =
    self.usernameConfirmed(ensUsername)

  proc transactionCompleted(self: View, success: bool, txHash: string, username: string, trxType: string) {.signal.}
  proc emitTransactionCompletedSignal*(self: View, success: bool, txHash: string, username: string, trxType: string) =
    self.transactionCompleted(success, txHash, username, trxType)

  proc removeEnsUsername*(self: View, chainId: int, ensUsername: string): bool {.slot.} =
    return self.delegate.removeEnsUsername(chainId, ensUsername)

  proc connectOwnedUsername*(self: View, ensUsername: string, isStatus: bool) {.slot.} =
    self.delegate.connectOwnedUsername(ensUsername, isStatus)

  proc getEnsRegisteredAddress*(self: View): string {.slot.} =
    return self.delegate.getEnsRegisteredAddress()

  proc getWalletDefaultAddress*(self: View): string {.slot.} =
    return self.delegate.getWalletDefaultAddress()

  proc getCurrentCurrency*(self: View): string {.slot.} =
    return self.delegate.getCurrentCurrency()

  proc getFiatValue*(self: View, cryptoBalance: string, cryptoSymbol: string): string {.slot.} =
    return self.delegate.getFiatValue(cryptoBalance, cryptoSymbol)

  proc getCryptoValue*(self: View, fiatAmount: string, cryptoSymbol: string): string {.slot.} =
    return self.delegate.getCryptoValue(fiatAmount, cryptoSymbol)

  proc getGasEthValue*(self: View, gweiValue: string, gasLimit: string): string {.slot.} =
    return self.delegate.getGasEthValue(gweiValue, gasLimit)

  proc getStatusTokenKey*(self: View): string {.slot.} =
    return self.delegate.getStatusTokenKey()

  proc setPrefferedEnsUsername*(self: View, ensUsername: string) {.slot.} =
    self.delegate.setPrefferedEnsUsername(ensUsername)
