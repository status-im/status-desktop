type
  KeycardInsertedState* = ref object of State

proc newKeycardInsertedState*(flowType: FlowType, backState: State): KeycardInsertedState =
  result = KeycardInsertedState()
  result.setup(flowType, StateType.KeycardInserted, backState)

proc delete*(self: KeycardInsertedState) =
  self.State.delete
  
method executeBackCommand*(self: KeycardInsertedState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method getNextSecondaryState*(self: KeycardInsertedState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if self.stateType == StateType.SelectExistingKeyPair:
      return createState(StateType.RecognizedKeycard, self.flowType, self)
    return createState(StateType.ReadingKeycard, self.flowType, self.getBackState)
  return createState(StateType.ReadingKeycard, self.flowType, nil)

method executePrimaryCommand*(self: KeycardInsertedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)