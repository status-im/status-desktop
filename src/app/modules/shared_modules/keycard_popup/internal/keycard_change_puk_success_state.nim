type
  ChangingKeycardPukSuccessState* = ref object of State

proc newChangingKeycardPukSuccessState*(flowType: FlowType, backState: State): ChangingKeycardPukSuccessState =
  result = ChangingKeycardPukSuccessState()
  result.setup(flowType, StateType.ChangingKeycardPukSuccess, backState)

proc delete*(self: ChangingKeycardPukSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ChangingKeycardPukSuccessState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePreTertiaryStateCommand*(self: ChangingKeycardPukSuccessState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)