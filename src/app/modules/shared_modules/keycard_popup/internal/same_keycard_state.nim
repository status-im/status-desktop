type
  SameKeycardState* = ref object of State

proc newSameKeycardState*(flowType: FlowType, backState: State): SameKeycardState =
  result = SameKeycardState()
  result.setup(flowType, StateType.SameKeycard, backState)

proc delete*(self: SameKeycardState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: SameKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.runLoadAccountFlow(seedPhraseLength = 0, seedPhrase = "", pin = controller.getPin())

method executeCancelCommand*(self: SameKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: SameKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)