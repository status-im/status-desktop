type
  CopyingKeycardSuccessState* = ref object of State

proc newCopyingKeycardSuccessState*(flowType: FlowType, backState: State): CopyingKeycardSuccessState =
  result = CopyingKeycardSuccessState()
  result.setup(flowType, StateType.CopyingKeycardSuccess, backState)

proc delete*(self: CopyingKeycardSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: CopyingKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: CopyingKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)