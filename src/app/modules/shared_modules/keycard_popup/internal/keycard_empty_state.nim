type
  KeycardEmptyState* = ref object of State

proc newKeycardEmptyState*(flowType: FlowType, backState: State): KeycardEmptyState =
  result = KeycardEmptyState()
  result.setup(flowType, StateType.KeycardEmpty, backState)

proc delete*(self: KeycardEmptyState) =
  self.State.delete

method executeTertiaryCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.Authentication:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)