type
  KeycardReadingKeycardState* = ref object of State

proc newKeycardReadingKeycardState*(flowType: FlowType, backState: State): KeycardReadingKeycardState =
  result = KeycardReadingKeycardState()
  result.setup(flowType, StateType.KeycardReadingKeycard, backState)

proc delete*(self: KeycardReadingKeycardState) =
  self.State.delete

method resolveKeycardNextState*(self: KeycardReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)