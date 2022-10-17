type
  ChangingKeycardPukFailureState* = ref object of State

proc newChangingKeycardPukFailureState*(flowType: FlowType, backState: State): ChangingKeycardPukFailureState =
  result = ChangingKeycardPukFailureState()
  result.setup(flowType, StateType.ChangingKeycardPukFailure, backState)

proc delete*(self: ChangingKeycardPukFailureState) =
  self.State.delete

method executePrimaryCommand*(self: ChangingKeycardPukFailureState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeTertiaryCommand*(self: ChangingKeycardPukFailureState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)