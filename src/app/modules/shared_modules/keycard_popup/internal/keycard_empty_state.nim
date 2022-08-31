type
  KeycardEmptyState* = ref object of State

proc newKeycardEmptyState*(flowType: FlowType, backState: State): KeycardEmptyState =
  result = KeycardEmptyState()
  result.setup(flowType, StateType.KeycardEmpty, backState)

proc delete*(self: KeycardEmptyState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)