type
  KeycardInsertedState* = ref object of State

proc newKeycardInsertedState*(flowType: FlowType, backState: State): KeycardInsertedState =
  result = KeycardInsertedState()
  result.setup(flowType, StateType.KeycardInserted, backState)

proc delete*(self: KeycardInsertedState) =
  self.State.delete
  
method getNextSecondaryState*(self: KeycardInsertedState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    return createState(StateType.ReadingKeycard, self.flowType, self.getBackState)
  return createState(StateType.ReadingKeycard, self.flowType, nil)

method executePrimaryCommand*(self: KeycardInsertedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)