type
  KeycardMaxPinRetriesReachedState* = ref object of State

proc newKeycardMaxPinRetriesReachedState*(flowType: FlowType, backState: State): KeycardMaxPinRetriesReachedState =
  result = KeycardMaxPinRetriesReachedState()
  result.setup(flowType, StateType.KeycardMaxPinRetriesReached, backState)

proc delete*(self: KeycardMaxPinRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardMaxPinRetriesReachedState, controller: Controller): State =
  return createState(StateType.KeycardRecover, self.flowType(), self.getBackState)