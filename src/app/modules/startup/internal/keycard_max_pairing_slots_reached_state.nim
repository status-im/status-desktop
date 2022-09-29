type
  KeycardMaxPairingSlotsReachedState* = ref object of State

proc newKeycardMaxPairingSlotsReachedState*(flowType: FlowType, backState: State): KeycardMaxPairingSlotsReachedState =
  result = KeycardMaxPairingSlotsReachedState()
  result.setup(flowType, StateType.KeycardMaxPairingSlotsReached, backState)

proc delete*(self: KeycardMaxPairingSlotsReachedState) =
  self.State.delete

method getNextPrimaryState*(self: KeycardMaxPairingSlotsReachedState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    return createState(StateType.KeycardRecover, self.flowType(), self)