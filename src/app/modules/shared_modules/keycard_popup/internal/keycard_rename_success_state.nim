type
  KeycardRenameSuccessState* = ref object of State

proc newKeycardRenameSuccessState*(flowType: FlowType, backState: State): KeycardRenameSuccessState =
  result = KeycardRenameSuccessState()
  result.setup(flowType, StateType.KeycardRenameSuccess, backState)

proc delete*(self: KeycardRenameSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeycardRenameSuccessState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: KeycardRenameSuccessState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)