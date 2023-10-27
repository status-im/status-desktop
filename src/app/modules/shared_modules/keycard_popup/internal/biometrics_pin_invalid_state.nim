type
  BiometricsPinInvalidState* = ref object of State

proc newBiometricsPinInvalidState*(flowType: FlowType, backState: State): BiometricsPinInvalidState =
  result = BiometricsPinInvalidState()
  result.setup(flowType, StateType.BiometricsPinInvalid, backState)

proc delete*(self: BiometricsPinInvalidState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: BiometricsPinInvalidState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.tryToObtainDataFromKeychain()

method executePreSecondaryStateCommand*(self: BiometricsPinInvalidState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.setUsePinFromBiometrics(true)
      controller.setOfferToStoreUpdatedPinToKeychain(true)

method getNextSecondaryState*(self: BiometricsPinInvalidState, controller: Controller): State =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      return createState(StateType.EnterPin, self.flowType, nil)

method executeCancelCommand*(self: BiometricsPinInvalidState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: BiometricsPinInvalidState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)