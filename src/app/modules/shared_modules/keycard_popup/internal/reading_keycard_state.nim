type
  ReadingKeycardState* = ref object of State

proc newReadingKeycardState*(flowType: FlowType, backState: State): ReadingKeycardState =
  result = ReadingKeycardState()
  result.setup(flowType, StateType.ReadingKeycard, backState)

proc delete*(self: ReadingKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: ReadingKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextSecondaryState*(self: ReadingKeycardState, controller: Controller): State =
  let (flowType, flowEvent) = controller.getLastReceivedKeycardData()
  # this is used in case a keycard is not inserted in the moment when flow is run (we're animating an insertion)
  return ensureReaderAndCardPresenceAndResolveNextState(self, flowType, flowEvent, controller)

method resolveKeycardNextState*(self: ReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  # this is used in case a keycard is inserted and we jump to the first meaningful screen
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)