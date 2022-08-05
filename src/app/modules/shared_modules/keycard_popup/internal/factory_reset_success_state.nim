type
  FactoryResetSuccessState* = ref object of State

proc newFactoryResetSuccessState*(flowType: FlowType, backState: State): FactoryResetSuccessState =
  result = FactoryResetSuccessState()
  result.setup(flowType, StateType.FactoryResetSuccess, backState)

proc delete*(self: FactoryResetSuccessState) =
  self.State.delete

method executePrimaryCommand*(self: FactoryResetSuccessState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
