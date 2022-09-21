type
  PinVerifiedState* = ref object of State

proc newPinVerifiedState*(flowType: FlowType, backState: State): PinVerifiedState =
  result = PinVerifiedState()
  result.setup(flowType, StateType.PinVerified, backState)

proc delete*(self: PinVerifiedState) =
  self.State.delete

method getNextPrimaryState*(self: PinVerifiedState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.DisplayKeycardContent:
      return createState(StateType.KeycardMetadataDisplay, self.flowType, nil)
  return nil

method executeTertiaryCommand*(self: PinVerifiedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.DisplayKeycardContent:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)