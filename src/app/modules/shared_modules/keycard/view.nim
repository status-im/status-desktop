import NimQml, strutils
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      flowState: FlowStateType
      keycardMode: KeycardMode
      keycardData: string # used to temporary store the data coming from keycard

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.flowState = FlowStateType.PluginKeycard

  proc flowStateChanged*(self: View) {.signal.}
  proc setFlowState*(self: View, value: FlowStateType) =
    if self.flowState == value:
      return
    self.flowState = value
    self.flowStateChanged()
  proc getFlowState*(self: View): string {.slot.} =
    return $self.flowState
  QtProperty[string] flowState:
    read = getFlowState
    notify = flowStateChanged

  proc keycardModeChanged*(self: View) {.signal.}
  proc setKeycardMode*(self: View, value: string) {.slot.} =
    if $self.keycardMode == value:
      return
    self.keycardMode = parseEnum[KeycardMode](value)
    self.keycardModeChanged()
  proc getKeycardModeAsString*(self: View): string {.slot.} =
    return $self.keycardMode
  proc getKeycardMode*(self: View): KeycardMode =
    return self.keycardMode
  QtProperty[string] keycardMode:
    read = getKeycardModeAsString
    write = setKeycardMode
    notify = keycardModeChanged

  proc keycardDataChanged*(self: View) {.signal.}
  proc setKeycardData*(self: View, value: string) =
    if self.keycardData == value:
      return
    self.keycardData = value
    self.keycardDataChanged()
  proc getKeycardData*(self: View): string {.slot.} =
    return self.keycardData
  QtProperty[string] keycardData:
    read = getKeycardData
    notify = keycardDataChanged

  proc checkKeycardPin*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkKeycardPin(pin)

  proc checkKeycardPuk*(self: View, puk: string): bool {.slot.} =
    return self.delegate.checkKeycardPuk(puk)

  proc checkRepeatedKeycardPinCurrent*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPinCurrent(pin)

  proc checkRepeatedKeycardPin*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPin(pin)

  proc checkSeedPhrase*(self: View, seedPhraseLength: int, seedPhrase: string): bool {.slot.} =
    return self.delegate.checkSeedPhrase(seedPhraseLength, seedPhrase)

  proc runLoadAccountFlow*(self: View) {.slot.} =
    self.delegate.runLoadAccountFlow()

  proc runLoginFlow*(self: View) {.slot.} =
    self.delegate.runLoginFlow()

  proc runRecoverAccountFlow*(self: View) {.slot.} =
    self.delegate.runRecoverAccountFlow()

  proc cancelFlow*(self: View) {.slot.} =
    self.delegate.cancelFlow()

  proc shouldExitKeycardFlow*(self: View): bool {.slot.} =
    return self.delegate.shouldExitKeycardFlow()

  proc backClicked*(self: View) {.slot.} =
    self.delegate.backClicked()

  proc nextState*(self: View) {.slot.} =
    self.delegate.nextState()

  proc getSeedPhrase*(self: View): string {.slot.} =
    return self.delegate.getSeedPhrase()

  proc continueWithCreatingProfile(self: View, seedPhrase: string) {.signal.}
  proc sendContinueWithCreatingProfileSignal*(self: View, seedPhrase: string) =
    self.continueWithCreatingProfile(seedPhrase)

  proc factoryReset*(self: View) {.slot.} =
    self.delegate.factoryReset()

  proc switchCard*(self: View) {.slot.} =
    self.delegate.switchCard()