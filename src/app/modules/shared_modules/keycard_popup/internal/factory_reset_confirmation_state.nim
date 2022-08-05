type
  FactoryResetConfirmationState* = ref object of State

proc newFactoryResetConfirmationState*(flowType: FlowType, backState: State): FactoryResetConfirmationState =
  result = FactoryResetConfirmationState()
  result.setup(flowType, StateType.FactoryResetConfirmation, backState)

proc delete*(self: FactoryResetConfirmationState) =
  self.State.delete

method executePrimaryCommand*(self: FactoryResetConfirmationState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.runGetAppInfoFlow(factoryReset = true)

method executeSecondaryCommand*(self: FactoryResetConfirmationState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextPrimaryState*(self: FactoryResetConfirmationState, controller: Controller): State =
  return createState(StateType.PluginReader, self.flowType, nil)