type
  KeycardEmptyState* = ref object of State

proc newKeycardEmptyState*(flowType: FlowType, backState: State): KeycardEmptyState =
  result = KeycardEmptyState()
  result.setup(flowType, StateType.KeycardEmpty, backState)

proc delete*(self: KeycardEmptyState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executeCancelCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)