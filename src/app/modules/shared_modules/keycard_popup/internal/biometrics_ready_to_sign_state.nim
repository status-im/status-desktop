type
  BiometricsReadyToSignState* = ref object of State

proc newBiometricsReadyToSignState*(flowType: FlowType, backState: State): BiometricsReadyToSignState =
  result = BiometricsReadyToSignState()
  result.setup(flowType, StateType.BiometricsReadyToSign, backState)

proc delete*(self: BiometricsReadyToSignState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: BiometricsReadyToSignState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.tryToObtainDataFromKeychain()

method executePreSecondaryStateCommand*(self: BiometricsReadyToSignState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.setUsePinFromBiometrics(true)

method getNextSecondaryState*(self: BiometricsReadyToSignState, controller: Controller): State =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      return createState(StateType.EnterPin, self.flowType, nil)

method executeCancelCommand*(self: BiometricsReadyToSignState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: BiometricsReadyToSignState, keycardFlowType: string, keycardEvent: KeycardEvent,
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
          if singletonInstance.userProfile.getUsingBiometricLogin() and not controller.usePinFromBiometrics():
            return createState(StateType.WrongKeychainPin, self.flowType, nil)
          return createState(StateType.WrongPin, self.flowType, nil)
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPIN and
        keycardEvent.error.len == 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueEnterPUK and
        keycardEvent.error.len == 0:
          if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
            return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
          return nil