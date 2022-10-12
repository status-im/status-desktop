type
  KeycardRenameFailureState* = ref object of State

proc newKeycardRenameFailureState*(flowType: FlowType, backState: State): KeycardRenameFailureState =
  result = KeycardRenameFailureState()
  result.setup(flowType, StateType.KeycardRenameFailure, backState)

proc delete*(self: KeycardRenameFailureState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardRenameFailureState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeTertiaryCommand*(self: KeycardRenameFailureState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)