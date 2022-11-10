type
  BiometricsPinFailedState* = ref object of State

proc newBiometricsPinFailedState*(flowType: FlowType, backState: State): BiometricsPinFailedState =
  result = BiometricsPinFailedState()
  result.setup(flowType, StateType.BiometricsPinFailed, backState)

proc delete*(self: BiometricsPinFailedState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: BiometricsPinFailedState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.tryToObtainDataFromKeychain()

method executePreSecondaryStateCommand*(self: BiometricsPinFailedState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setUsePinFromBiometrics(true)

method getNextSecondaryState*(self: BiometricsPinFailedState, controller: Controller): State =
  if self.flowType == FlowType.Authentication:
    return createState(StateType.EnterPin, self.flowType, nil)

method executeCancelCommand*(self: BiometricsPinFailedState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.setPin("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: BiometricsPinFailedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)