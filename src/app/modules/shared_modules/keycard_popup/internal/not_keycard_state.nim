type
  NotKeycardState* = ref object of State

proc newNotKeycardState*(flowType: FlowType, backState: State): NotKeycardState =
  result = NotKeycardState()
  result.setup(flowType, StateType.NotKeycard, backState)

proc delete*(self: NotKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: NotKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)