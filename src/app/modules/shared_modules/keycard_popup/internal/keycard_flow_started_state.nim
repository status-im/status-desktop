type KeycardFlowStartedState* = ref object of State

proc newKeycardFlowStartedState*(
    flowType: FlowType, backState: State
): KeycardFlowStartedState =
  result = KeycardFlowStartedState()
  result.setup(flowType, StateType.KeycardFlowStarted, backState)

proc delete*(self: KeycardFlowStartedState) =
  self.State.delete
