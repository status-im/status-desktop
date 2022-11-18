type
  RemoveKeycardState* = ref object of State

proc newRemoveKeycardState*(flowType: FlowType, backState: State): RemoveKeycardState =
  result = RemoveKeycardState()
  result.setup(flowType, StateType.RemoveKeycard, backState)

proc delete*(self: RemoveKeycardState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: RemoveKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.runLoadAccountFlow(seedPhraseLength = 0, seedPhrase = "", pin = controller.getPinForKeycardCopy())

method executeCancelCommand*(self: RemoveKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: RemoveKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)