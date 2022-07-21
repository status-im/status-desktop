type
  KeycardLockedState* = ref object of State

proc newKeycardLockedState*(flowType: FlowType, backState: State): KeycardLockedState =
  result = KeycardLockedState()
  result.setup(flowType, StateType.KeycardLocked, backState)

proc delete*(self: KeycardLockedState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardLockedState, controller: Controller): State =
  return createState(StateType.KeycardEnterSeedPhraseWords, self.flowType, self)