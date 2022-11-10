type
  UnlockKeycardSuccessState* = ref object of State

proc newUnlockKeycardSuccessState*(flowType: FlowType, backState: State): UnlockKeycardSuccessState =
  result = UnlockKeycardSuccessState()
  result.setup(flowType, StateType.UnlockKeycardSuccess, backState)

proc delete*(self: UnlockKeycardSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: UnlockKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePreTertiaryStateCommand*(self: UnlockKeycardSuccessState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)