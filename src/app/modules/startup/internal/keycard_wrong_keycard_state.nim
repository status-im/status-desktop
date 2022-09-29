type
  KeycardWrongKeycardState* = ref object of State

proc newKeycardWrongKeycardState*(flowType: FlowType, backState: State): KeycardWrongKeycardState =
  result = KeycardWrongKeycardState()
  result.setup(flowType, StateType.KeycardWrongKeycard, backState)

proc delete*(self: KeycardWrongKeycardState) =
  self.State.delete