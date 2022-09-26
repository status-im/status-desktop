import NimQml
import io_interface
import internal/[state, state_wrapper]
import models/[key_pair_model, key_pair_item, key_pair_selected_item]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentState: StateWrapper
      currentStateVariant: QVariant
      keyPairModel: KeyPairModel
      keyPairModelVariant: QVariant
      selectedKeyPairItem: KeyPairSelectedItem
      selectedKeyPairItemVariant: QVariant
      keyPairStoredOnKeycardIsKnown: bool
      keyPairStoredOnKeycard: KeyPairSelectedItem
      keyPairStoredOnKeycardVariant: QVariant
      keyPairForAuthentication: KeyPairSelectedItem
      keyPairForAuthenticationVariant: QVariant
      keycardData: string # used to temporary store the data coming from keycard, depends on current state different data may be stored

  proc delete*(self: View) =
    self.currentStateVariant.delete
    self.currentState.delete
    if not self.keyPairModel.isNil:
      self.keyPairModel.delete
    if not self.keyPairModelVariant.isNil:
      self.keyPairModelVariant.delete
    if not self.selectedKeyPairItem.isNil:
      self.selectedKeyPairItem.delete
    if not self.selectedKeyPairItemVariant.isNil:
      self.selectedKeyPairItemVariant.delete
    if not self.keyPairStoredOnKeycard.isNil:
      self.keyPairStoredOnKeycard.delete
    if not self.keyPairStoredOnKeycardVariant.isNil:
      self.keyPairStoredOnKeycardVariant.delete
    if not self.keyPairForAuthentication.isNil:
      self.keyPairForAuthentication.delete
    if not self.keyPairForAuthenticationVariant.isNil:
      self.keyPairForAuthenticationVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.currentState = newStateWrapper()
    result.currentStateVariant = newQVariant(result.currentState)

    signalConnect(result.currentState, "backActionClicked()", result, "onBackActionClicked()", 2)
    signalConnect(result.currentState, "primaryActionClicked()", result, "onPrimaryActionClicked()", 2)
    signalConnect(result.currentState, "secondaryActionClicked()", result, "onSecondaryActionClicked()", 2)
    signalConnect(result.currentState, "tertiaryActionClicked()", result, "onTertiaryActionClicked()", 2)

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

  proc onBackActionClicked*(self: View) {.slot.} =
    self.delegate.onBackActionClicked()

  proc onPrimaryActionClicked*(self: View) {.slot.} =
    self.delegate.onPrimaryActionClicked()

  proc onSecondaryActionClicked*(self: View) {.slot.} =
    self.delegate.onSecondaryActionClicked()

  proc onTertiaryActionClicked*(self: View) {.slot.} =
    self.delegate.onTertiaryActionClicked()

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

  proc createKeyPairStoredOnKeycard*(self: View) =
    if self.keyPairStoredOnKeycard.isNil:
      self.keyPairStoredOnKeycard = newKeyPairSelectedItem()
    if self.keyPairStoredOnKeycardVariant.isNil:
      self.keyPairStoredOnKeycardVariant = newQVariant(self.keyPairStoredOnKeycard)

  proc createKeyPairModel*(self: View, items: seq[KeyPairItem]) =
    if self.keyPairModel.isNil:
      self.keyPairModel = newKeyPairModel()
    if self.keyPairModelVariant.isNil:
      self.keyPairModelVariant = newQVariant(self.keyPairModel)
    if self.selectedKeyPairItem.isNil:
      self.selectedKeyPairItem = newKeyPairSelectedItem()
    if self.selectedKeyPairItemVariant.isNil:
      self.selectedKeyPairItemVariant = newQVariant(self.selectedKeyPairItem)
    self.keyPairModel.setItems(items)
    self.keyPairModelChanged()

  proc getSelectedKeyPairItem*(self: View): QVariant {.slot.} =
    if self.selectedKeyPairItemVariant.isNil:
      return newQVariant()
    return self.selectedKeyPairItemVariant
  QtProperty[QVariant] selectedKeyPairItem:
    read = getSelectedKeyPairItem
  proc setSelectedKeyPair*(self: View, publicKey: string) {.slot.} =
    let item = self.keyPairModel.findItemByPublicKey(publicKey)
    self.delegate.setSelectedKeyPair(item)
    self.selectedKeyPairItem.setItem(item)

  proc getKeyPairStoredOnKeycardIsKnown*(self: View): bool {.slot.} =
    return self.keyPairStoredOnKeycardIsKnown
  QtProperty[bool] keyPairStoredOnKeycardIsKnown:
    read = getKeyPairStoredOnKeycardIsKnown
  proc setKeyPairStoredOnKeycardIsKnown*(self: View, value: bool) =
    self.keyPairStoredOnKeycardIsKnown = value

  proc getKeyPairStoredOnKeycard*(self: View): QVariant {.slot.} =
    if self.keyPairStoredOnKeycardVariant.isNil:
      return newQVariant()
    return self.keyPairStoredOnKeycardVariant
  QtProperty[QVariant] keyPairStoredOnKeycard:
    read = getKeyPairStoredOnKeycard
  proc setKeyPairStoredOnKeycard*(self: View, item: KeyPairItem) =
    self.keyPairStoredOnKeycard.setItem(item)

  proc createKeyPairForAuthentication*(self: View) =
    if self.keyPairForAuthentication.isNil:
      self.keyPairForAuthentication = newKeyPairSelectedItem()
    if self.keyPairForAuthenticationVariant.isNil:
      self.keyPairForAuthenticationVariant = newQVariant(self.keyPairForAuthentication)

  proc getKeyPairForAuthentication*(self: View): QVariant {.slot.} =
    if self.keyPairForAuthenticationVariant.isNil:
      return newQVariant()
    return self.keyPairForAuthenticationVariant
  QtProperty[QVariant] keyPairForAuthentication:
    read = getKeyPairForAuthentication
  proc setKeyPairForAuthentication*(self: View, item: KeyPairItem) =
    self.keyPairForAuthentication.setItem(item)
  proc setLockedPropForKeyPairForAuthentication*(self: View, locked: bool) =
    if self.keyPairForAuthentication.isNil:
      return
    self.keyPairForAuthentication.updateLockedState(locked)

  proc setPin*(self: View, value: string) {.slot.} =
    self.delegate.setPin(value)

  proc setPuk*(self: View, value: string) {.slot.} =
    self.delegate.setPuk(value)

  proc setPassword*(self: View, value: string) {.slot.} =
    self.delegate.setPassword(value)

  proc checkRepeatedKeycardPinWhileTyping*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPinWhileTyping(pin)

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