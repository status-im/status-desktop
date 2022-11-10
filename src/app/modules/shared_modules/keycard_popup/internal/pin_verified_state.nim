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
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard:
      return createState(StateType.KeycardMetadataDisplay, self.flowType, nil)
  if self.flowType == FlowType.ChangeKeycardPin:
    return createState(StateType.CreatePin, self.flowType, nil)
  if self.flowType == FlowType.ChangeKeycardPuk:
    return createState(StateType.CreatePuk, self.flowType, nil)
  if self.flowType == FlowType.ChangePairingCode:
    return createState(StateType.CreatePairingCode, self.flowType, nil)

method executePreTertiaryStateCommand*(self: PinVerifiedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)