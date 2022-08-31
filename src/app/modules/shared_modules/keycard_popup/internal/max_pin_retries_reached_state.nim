type
  MaxPinRetriesReachedState* = ref object of State

proc newMaxPinRetriesReachedState*(flowType: FlowType, backState: State): MaxPinRetriesReachedState =
  result = MaxPinRetriesReachedState()
  result.setup(flowType, StateType.MaxPinRetriesReached, backState)

proc delete*(self: MaxPinRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: MaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  return nil

method executeSecondaryCommand*(self: MaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)