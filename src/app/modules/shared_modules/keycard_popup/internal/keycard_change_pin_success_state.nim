type
  ChangingKeycardPinSuccessState* = ref object of State

proc newChangingKeycardPinSuccessState*(flowType: FlowType, backState: State): ChangingKeycardPinSuccessState =
  result = ChangingKeycardPinSuccessState()
  result.setup(flowType, StateType.ChangingKeycardPinSuccess, backState)

proc delete*(self: ChangingKeycardPinSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ChangingKeycardPinSuccessState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPin:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePreTertiaryStateCommand*(self: ChangingKeycardPinSuccessState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPin:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)