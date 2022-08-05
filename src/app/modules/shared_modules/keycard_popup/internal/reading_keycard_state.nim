type
  ReadingKeycardState* = ref object of State

proc newReadingKeycardState*(flowType: FlowType, backState: State): ReadingKeycardState =
  result = ReadingKeycardState()
  result.setup(flowType, StateType.ReadingKeycard, backState)

proc delete*(self: ReadingKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: ReadingKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: ReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNotAKeycard:
        return createState(StateType.NotKeycard, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0:
      if keycardEvent.error == ErrorOk:
        return createState(StateType.FactoryResetSuccess, self.flowType, nil)
      if keycardEvent.error == ErrorNoKeys:
        return createState(StateType.KeycardEmpty, self.flowType, nil)
      controller.setContainsMetadata(keycardEvent.error != ErrorNoData)
      return createState(StateType.RecognizedKeycard, self.flowType, nil)