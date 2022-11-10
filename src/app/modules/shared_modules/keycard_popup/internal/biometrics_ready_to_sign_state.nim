type
  BiometricsReadyToSignState* = ref object of State

proc newBiometricsReadyToSignState*(flowType: FlowType, backState: State): BiometricsReadyToSignState =
  result = BiometricsReadyToSignState()
  result.setup(flowType, StateType.BiometricsReadyToSign, backState)

proc delete*(self: BiometricsReadyToSignState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: BiometricsReadyToSignState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.tryToObtainDataFromKeychain()

method executePreSecondaryStateCommand*(self: BiometricsReadyToSignState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setUsePinFromBiometrics(true)

method getNextSecondaryState*(self: BiometricsReadyToSignState, controller: Controller): State =
  if self.flowType == FlowType.Authentication:
    return createState(StateType.EnterPin, self.flowType, nil)

method executeCancelCommand*(self: BiometricsReadyToSignState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.setPin("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: BiometricsReadyToSignState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)