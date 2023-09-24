type
  ReadingKeycardState* = ref object of State

proc newReadingKeycardState*(flowType: FlowType, backState: State): ReadingKeycardState =
  result = ReadingKeycardState()
  result.setup(flowType, StateType.ReadingKeycard, backState)

proc delete*(self: ReadingKeycardState) =
  self.State.delete

method executePreBackStateCommand*(self: ReadingKeycardState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method executeCancelCommand*(self: ReadingKeycardState, controller: Controller) =
  error "reading state must not be canceled"

method getNextSecondaryState*(self: ReadingKeycardState, controller: Controller): State =
  let (flowType, flowEvent) = controller.getLastReceivedKeycardData()
  # this is used in case a keycard is not inserted in the moment when flow is run (we're animating an insertion)
  return self.resolveKeycardNextState(flowType, flowEvent, controller)

method resolveKeycardNextState*(self: ReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  return readingKeycard(self, keycardFlowType, keycardEvent, controller)