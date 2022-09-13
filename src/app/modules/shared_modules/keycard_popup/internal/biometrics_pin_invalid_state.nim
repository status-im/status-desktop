type
  BiometricsPinInvalidState* = ref object of State

proc newBiometricsPinInvalidState*(flowType: FlowType, backState: State): BiometricsPinInvalidState =
  result = BiometricsPinInvalidState()
  result.setup(flowType, StateType.BiometricsPinInvalid, backState)

proc delete*(self: BiometricsPinInvalidState) =
  self.State.delete

method executePrimaryCommand*(self: BiometricsPinInvalidState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.tryToObtainDataFromKeychain()

method executeSecondaryCommand*(self: BiometricsPinInvalidState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setUsePinFromBiometrics(true)

method getNextSecondaryState*(self: BiometricsPinInvalidState, controller: Controller): State =
  if self.flowType == FlowType.Authentication:
    return createState(StateType.EnterPin, self.flowType, nil)

method executeTertiaryCommand*(self: BiometricsPinInvalidState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.setPin("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: BiometricsPinInvalidState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)