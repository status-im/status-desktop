import NimQml
import io_interface
import internal/[state, state_wrapper]
import app/modules/shared_models/[keypair_item, derived_address_model]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentState: StateWrapper
      currentStateVariant: QVariant
      selectedKeypair: KeyPairItem
      selectedKeypairVariant: QVariant
      privateKeyAccAddress: DerivedAddressItem
      privateKeyAccAddressVariant: QVariant
      enteredPrivateKeyMatchTheKeypair: bool

  proc delete*(self: View) =
    self.currentStateVariant.delete
    self.currentState.delete
    self.selectedKeypair.delete
    self.selectedKeypairVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.currentState = newStateWrapper()
    result.currentStateVariant = newQVariant(result.currentState)
    result.selectedKeypair = newKeyPairItem()
    result.selectedKeypairVariant = newQVariant(result.selectedKeypair)
    result.privateKeyAccAddress = newDerivedAddressItem()
    result.privateKeyAccAddressVariant = newQVariant(result.privateKeyAccAddress)
    result.enteredPrivateKeyMatchTheKeypair = false

    signalConnect(result.currentState, "backActionClicked()", result, "onBackActionClicked()", 2)
    signalConnect(result.currentState, "cancelActionClicked()", result, "onCancelActionClicked()", 2)
    signalConnect(result.currentState, "primaryActionClicked()", result, "onPrimaryActionClicked()", 2)

  proc currentStateObj*(self: View): State =
    return self.currentState.getStateObj()

  proc setCurrentState*(self: View, state: State) =
    self.currentState.setStateObj(state)
  proc getCurrentState(self: View): QVariant {.slot.} =
    return self.currentStateVariant
  QtProperty[QVariant] currentState:
    read = getCurrentState

  proc onBackActionClicked*(self: View) {.slot.} =
    self.delegate.onBackActionClicked()

  proc onCancelActionClicked*(self: View) {.slot.} =
    self.delegate.onCancelActionClicked()

  proc onPrimaryActionClicked*(self: View) {.slot.} =
    self.delegate.onPrimaryActionClicked()

  proc getSelectedKeypair*(self: View): KeyPairItem =
    return self.selectedKeypair
  proc getSelectedKeypairAsVariant*(self: View): QVariant {.slot.} =
    return self.selectedKeypairVariant
  QtProperty[QVariant] selectedKeypair:
    read = getSelectedKeypairAsVariant

  proc setSelectedKeypair*(self: View, item: KeyPairItem) =
    self.selectedKeypair.setItem(item)

  proc getPrivateKeyAccAddress*(self: View): DerivedAddressItem =
    return self.privateKeyAccAddress

  proc privateKeyAccAddressChanged*(self: View) {.signal.}
  proc getPrivateKeyAccAddressVariant*(self: View): QVariant {.slot.} =
    return self.privateKeyAccAddressVariant
  QtProperty[QVariant] privateKeyAccAddress:
    read = getPrivateKeyAccAddressVariant
    notify = privateKeyAccAddressChanged

  proc setPrivateKeyAccAddress*(self: View, item: DerivedAddressItem) =
    self.privateKeyAccAddress.setItem(item)
    self.privateKeyAccAddressChanged()

  proc changePrivateKey*(self: View, privateKey: string) {.slot.} =
    self.delegate.changePrivateKey(privateKey)

  proc changeSeedPhrase*(self: View, seedPhrase: string) {.slot.} =
    self.delegate.changeSeedPhrase(seedPhrase)

  proc validSeedPhrase*(self: View, seedPhrase: string): bool {.slot.} =
    return self.delegate.validSeedPhrase(seedPhrase)

  proc enteredPrivateKeyMatchTheKeypairChanged(self: View) {.signal.}
  proc getEnteredPrivateKeyMatchTheKeypair*(self: View): bool {.slot.} =
    return self.enteredPrivateKeyMatchTheKeypair
  QtProperty[bool] enteredPrivateKeyMatchTheKeypair:
    read = getEnteredPrivateKeyMatchTheKeypair
    notify = enteredPrivateKeyMatchTheKeypairChanged

  proc setEnteredPrivateKeyMatchTheKeypair*(self: View, value: bool) =
    self.enteredPrivateKeyMatchTheKeypair = value
    self.enteredPrivateKeyMatchTheKeypairChanged()
