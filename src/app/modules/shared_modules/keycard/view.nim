import NimQml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      flowState: FlowStateType

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

  proc checkKeycardPin*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkKeycardPin(pin)

  proc checkRepeatedKeycardPinCurrent*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPinCurrent(pin)

  proc checkRepeatedKeycardPin*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPin(pin)

  proc startOnboardingKeycardFlow*(self: View) {.slot.} =
    self.delegate.startOnboardingKeycardFlow()

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