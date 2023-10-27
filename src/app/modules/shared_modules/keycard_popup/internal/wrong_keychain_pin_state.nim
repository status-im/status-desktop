type
  WrongKeychainPinState* = ref object of State

proc newWrongKeychainPinState*(flowType: FlowType, backState: State): WrongKeychainPinState =
  result = WrongKeychainPinState()
  result.setup(flowType, StateType.WrongKeychainPin, backState)

proc delete*(self: WrongKeychainPinState) =
  self.State.delete

method getNextPrimaryState*(self: WrongKeychainPinState, controller: Controller): State =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())
  return nil

method executeCancelCommand*(self: WrongKeychainPinState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongKeychainPinState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorPIN:
        controller.setRemainingAttempts(keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          controller.tryToStoreDataToKeychain(controller.getPin())
          controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
          return nil