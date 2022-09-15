type
  InsertKeycardState* = ref object of State

proc newInsertKeycardState*(flowType: FlowType, backState: State): InsertKeycardState =
  result = InsertKeycardState()
  result.setup(flowType, StateType.InsertKeycard, backState)

proc delete*(self: InsertKeycardState) =
  self.State.delete

method executeBackCommand*(self: InsertKeycardState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method executePrimaryCommand*(self: InsertKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executeTertiaryCommand*(self: InsertKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.Authentication:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: InsertKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = true))
      return nil
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
    if self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.KeycardInserted, self.flowType, self.getBackState)
    return createState(StateType.KeycardInserted, self.flowType, nil)
  return nil