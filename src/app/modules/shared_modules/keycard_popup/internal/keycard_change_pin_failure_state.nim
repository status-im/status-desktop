type
  ChangingKeycardPinFailureState* = ref object of State

proc newChangingKeycardPinFailureState*(flowType: FlowType, backState: State): ChangingKeycardPinFailureState =
  result = ChangingKeycardPinFailureState()
  result.setup(flowType, StateType.ChangingKeycardPinFailure, backState)

proc delete*(self: ChangingKeycardPinFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ChangingKeycardPinFailureState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPin:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: ChangingKeycardPinFailureState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPin:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)