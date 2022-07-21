type
  LoginState* = ref object of State

proc newLoginState*(flowType: FlowType, backState: State): LoginState =
  result = LoginState()
  result.setup(flowType, StateType.Login, backState)

proc delete*(self: LoginState) =
  self.State.delete

method executePrimaryCommand*(self: LoginState, controller: Controller) =
  controller.login()

method getNextSecondaryState*(self: LoginState, controller: Controller): State =
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginState, controller: Controller): State =
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return nil
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.LoginKeycardInsertKeycard, self.flowType, nil)