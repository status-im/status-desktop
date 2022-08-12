import NimQml
import io_interface
import internal/[state, state_wrapper]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentState: StateWrapper
      currentStateVariant: QVariant
      keycardData: string # used to temporary store the data coming from keycard, depends on current state different data may be stored

  proc delete*(self: View) =
    self.currentStateVariant.delete
    self.currentState.delete
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

  proc currentStateObj*(self: View): State =
    return self.currentState.getStateObj()

  proc setCurrentState*(self: View, state: State) =
    self.currentState.setStateObj(state)
  proc getCurrentState(self: View): QVariant {.slot.} =
    return self.currentStateVariant
  QtProperty[QVariant] currentState:
    read = getCurrentState

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

  proc onBackActionClicked*(self: View) {.slot.} =
    self.delegate.onBackActionClicked()

  proc onPrimaryActionClicked*(self: View) {.slot.} =
    self.delegate.onPrimaryActionClicked()

  proc onSecondaryActionClicked*(self: View) {.slot.} =
    self.delegate.onSecondaryActionClicked()

  proc runFactoryResetFlow*(self: View) {.slot.} =
    self.delegate.runFactoryResetFlow()