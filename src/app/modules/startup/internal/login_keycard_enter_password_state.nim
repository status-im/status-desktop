type
  LoginKeycardEnterPasswordState* = ref object of State

proc newLoginKeycardEnterPasswordState*(flowType: FlowType, backState: State): LoginKeycardEnterPasswordState =
  result = LoginKeycardEnterPasswordState()
  result.setup(flowType, StateType.LoginKeycardEnterPassword, backState)

proc delete*(self: LoginKeycardEnterPasswordState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardEnterPasswordState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()

method getNextTertiaryState*(self: LoginKeycardEnterPasswordState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginKeycardEnterPasswordState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)