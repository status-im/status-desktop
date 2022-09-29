type
  KeycardMaxPukRetriesReachedState* = ref object of State

proc newKeycardMaxPukRetriesReachedState*(flowType: FlowType, backState: State): KeycardMaxPukRetriesReachedState =
  result = KeycardMaxPukRetriesReachedState()
  result.setup(flowType, StateType.KeycardMaxPukRetriesReached, backState)

proc delete*(self: KeycardMaxPukRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardMaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.KeycardRecover, self.flowType(), self)