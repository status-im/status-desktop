type
  CopyingKeycardFailureState* = ref object of State

proc newCopyingKeycardFailureState*(flowType: FlowType, backState: State): CopyingKeycardFailureState =
  result = CopyingKeycardFailureState()
  result.setup(flowType, StateType.CopyingKeycardFailure, backState)

proc delete*(self: CopyingKeycardFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: CopyingKeycardFailureState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: CopyingKeycardFailureState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)