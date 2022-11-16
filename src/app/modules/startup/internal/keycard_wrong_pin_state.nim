type
  KeycardWrongPinState* = ref object of State
    pinValid: bool

proc newKeycardWrongPinState*(flowType: FlowType, backState: State): KeycardWrongPinState =
  result = KeycardWrongPinState()
  result.setup(flowType, StateType.KeycardWrongPin, backState)
  result.pinValid = false

proc delete*(self: KeycardWrongPinState) =
  self.State.delete

method executeBackCommand*(self: KeycardWrongPinState, controller: Controller) =
  controller.setPin("")

method executePrimaryCommand*(self: KeycardWrongPinState, controller: Controller) =
  self.pinValid = controller.getPin().len == PINLengthForStatusApp
  if self.pinValid:
    controller.enterKeycardPin(controller.getPin())
  
method resolveKeycardNextState*(self: KeycardWrongPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceOnboarding(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
        controller.setRemainingAttempts(keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        return createState(StateType.KeycardMaxPinRetriesReached, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.KeycardMaxPinRetriesReached, self.flowType, self.getBackState)
        return nil
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setKeycardEvent(keycardEvent)
      if not defined(macosx):
        controller.setupKeycardAccount(false)
        return nil
      return createState(StateType.Biometrics, self.flowType, self)