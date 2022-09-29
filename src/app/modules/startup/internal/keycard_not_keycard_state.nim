type
  KeycardNotKeycardState* = ref object of State

proc newKeycardNotKeycardState*(flowType: FlowType, backState: State): KeycardNotKeycardState =
  result = KeycardNotKeycardState()
  result.setup(flowType, StateType.KeycardNotKeycard, backState)

proc delete*(self: KeycardNotKeycardState) =
  self.State.delete