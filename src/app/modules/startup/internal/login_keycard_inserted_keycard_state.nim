type
  LoginKeycardInsertedKeycardState* = ref object of State

proc newLoginKeycardInsertedKeycardState*(flowType: FlowType, backState: State): LoginKeycardInsertedKeycardState =
  result = LoginKeycardInsertedKeycardState()
  result.setup(flowType, StateType.LoginKeycardInsertedKeycard, backState)

proc delete*(self: LoginKeycardInsertedKeycardState) =
  self.State.delete

method getNextPrimaryState*(self: LoginKeycardInsertedKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    return createState(StateType.LoginKeycardReadingKeycard, self.flowType, nil)
