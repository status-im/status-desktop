import NimQml
import io_interface
import internal/[state, state_wrapper]
import models/[key_pair_model, key_pair_item]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentState: StateWrapper
      currentStateVariant: QVariant
      keyPairModel: KeyPairModel
      keyPairModelVariant: QVariant
      keyPairStoredOnKeycardIsKnown: bool
      keyPairForAuthentication: KeyPairItem
      keyPairForAuthenticationVariant: QVariant
      keyPairForProcessing: KeyPairItem
      keyPairForProcessingVariant: QVariant
      keycardData: string # used to temporary store the data coming from keycard, depends on current state different data may be stored
      remainingAttempts: int

  proc delete*(self: View) =
    self.currentStateVariant.delete
    self.currentState.delete
    if not self.keyPairModel.isNil:
      self.keyPairModel.delete
    if not self.keyPairModelVariant.isNil:
      self.keyPairModelVariant.delete
    if not self.keyPairForAuthentication.isNil:
      self.keyPairForAuthentication.delete
    if not self.keyPairForAuthenticationVariant.isNil:
      self.keyPairForAuthenticationVariant.delete
    if not self.keyPairForProcessing.isNil:
      self.keyPairForProcessing.delete
    if not self.keyPairForProcessingVariant.isNil:
      self.keyPairForProcessingVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.currentState = newStateWrapper()
    result.currentStateVariant = newQVariant(result.currentState)
    result.remainingAttempts = -1

    signalConnect(result.currentState, "backActionClicked()", result, "onBackActionClicked()", 2)
    signalConnect(result.currentState, "cancelActionClicked()", result, "onCancelActionClicked()", 2)
    signalConnect(result.currentState, "primaryActionClicked()", result, "onPrimaryActionClicked()", 2)
    signalConnect(result.currentState, "secondaryActionClicked()", result, "onSecondaryActionClicked()", 2)

  proc currentStateObj*(self: View): State =
    return self.currentState.getStateObj()

  proc setCurrentState*(self: View, state: State) =
    self.currentState.setStateObj(state)
  proc getCurrentState(self: View): QVariant {.slot.} =
    return self.currentStateVariant
  QtProperty[QVariant] currentState:
    read = getCurrentState

  proc keycardDataChanged*(self: View) {.signal.}
  proc setKeycardData*(self: View, value: string) {.slot.} =
    if self.keycardData == value:
      return
    self.keycardData = value
    self.keycardDataChanged()
  proc getKeycardData*(self: View): string {.slot.} =
    return self.keycardData
  QtProperty[string] keycardData:
    read = getKeycardData
    write = setKeycardData
    notify = keycardDataChanged

  proc remainingAttemptsChanged*(self: View) {.signal.}
  proc setRemainingAttempts*(self: View, value: int) =
    if self.remainingAttempts == value:
      return
    self.remainingAttempts = value
    self.remainingAttemptsChanged()
  proc getRemainingAttempts*(self: View): int {.slot.} =
    return self.remainingAttempts
  QtProperty[int] remainingAttempts:
    read = getRemainingAttempts
    notify = remainingAttemptsChanged

  proc onBackActionClicked*(self: View) {.slot.} =
    self.delegate.onBackActionClicked()

  proc onCancelActionClicked*(self: View) {.slot.} =
    self.delegate.onCancelActionClicked()

  proc onPrimaryActionClicked*(self: View) {.slot.} =
    self.delegate.onPrimaryActionClicked()

  proc onSecondaryActionClicked*(self: View) {.slot.} =
    self.delegate.onSecondaryActionClicked()

  proc keyPairModel*(self: View): KeyPairModel =
    return self.keyPairModel

  proc keyPairModelChanged(self: View) {.signal.}
  proc getKeyPairModel(self: View): QVariant {.slot.} =
    if self.keyPairModelVariant.isNil:
      return newQVariant()
    return self.keyPairModelVariant
  QtProperty[QVariant] keyPairModel:
    read = getKeyPairModel
    notify = keyPairModelChanged

  proc createKeyPairModel*(self: View, items: seq[KeyPairItem]) =
    if self.keyPairModel.isNil:
      self.keyPairModel = newKeyPairModel()
    if self.keyPairModelVariant.isNil:
      self.keyPairModelVariant = newQVariant(self.keyPairModel)
    self.keyPairModel.setItems(items)
    self.keyPairModelChanged()

  proc setSelectedKeyPair*(self: View, publicKey: string) {.slot.} =
    let item = self.keyPairModel.findItemByPublicKey(publicKey)
    self.delegate.setSelectedKeyPair(item)

  proc getKeyPairStoredOnKeycardIsKnown*(self: View): bool {.slot.} =
    return self.keyPairStoredOnKeycardIsKnown
  QtProperty[bool] keyPairStoredOnKeycardIsKnown:
    read = getKeyPairStoredOnKeycardIsKnown
  proc setKeyPairStoredOnKeycardIsKnown*(self: View, value: bool) =
    self.keyPairStoredOnKeycardIsKnown = value

  proc getKeyPairForAuthentication*(self: View): QVariant {.slot.} =
    if self.keyPairForAuthenticationVariant.isNil:
      return newQVariant()
    return self.keyPairForAuthenticationVariant
  QtProperty[QVariant] keyPairForAuthentication:
    read = getKeyPairForAuthentication
  proc setKeyPairForAuthentication*(self: View, item: KeyPairItem) =
    if self.keyPairForAuthentication.isNil:
      self.keyPairForAuthentication = newKeyPairItem()
    if self.keyPairForAuthenticationVariant.isNil:
      self.keyPairForAuthenticationVariant = newQVariant(self.keyPairForAuthentication)
    self.keyPairForAuthentication.setItem(item)
  proc setLockedPropForKeyPairForAuthentication*(self: View, locked: bool) =
    if self.keyPairForAuthentication.isNil:
      return
    self.keyPairForAuthentication.setLocked(locked)

  proc getKeyPairForProcessing*(self: View): KeyPairItem =
    return self.keyPairForProcessing
  proc getKeyPairForProcessingAsVariant*(self: View): QVariant {.slot.} =
    if self.keyPairForProcessingVariant.isNil:
      return newQVariant()
    return self.keyPairForProcessingVariant
  QtProperty[QVariant] keyPairForProcessing:
    read = getKeyPairForProcessingAsVariant
  proc setKeyPairForProcessing*(self: View, item: KeyPairItem) =
    if self.keyPairForProcessing.isNil:
      self.keyPairForProcessing = newKeyPairItem()
    if self.keyPairForProcessingVariant.isNil:
      self.keyPairForProcessingVariant = newQVariant(self.keyPairForProcessing)
    self.keyPairForProcessing.setItem(item)

  proc setPin*(self: View, value: string) {.slot.} =
    self.delegate.setPin(value)

  proc setPuk*(self: View, value: string) {.slot.} =
    self.delegate.setPuk(value)

  proc setPassword*(self: View, value: string) {.slot.} =
    self.delegate.setPassword(value)

  proc getNameFromKeycard*(self: View): string {.slot.} =
    return self.delegate.getNameFromKeycard()

  proc setPairingCode*(self: View, value: string) {.slot.} =
    self.delegate.setPairingCode(value)

  proc checkRepeatedKeycardPinWhileTyping*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPinWhileTyping(pin)

  proc checkRepeatedKeycardPukWhileTyping*(self: View, puk: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPukWhileTyping(puk)

  proc getMnemonic*(self: View): string {.slot.} =
    return self.delegate.getMnemonic()

  proc setSeedPhrase*(self: View, value: string) {.slot.} =
    self.delegate.setSeedPhrase(value)

  proc getSeedPhrase*(self: View): string {.slot.} =
    return self.delegate.getSeedPhrase()

  proc validSeedPhrase*(self: View, value: string): bool {.slot.} =
    return self.delegate.validSeedPhrase(value)
  
  proc migratingProfileKeyPair*(self: View): bool {.slot.} =
    return self.delegate.migratingProfileKeyPair()

  proc getSigningPhrase*(self: View): string {.slot.} =
    return self.delegate.getSigningPhrase()