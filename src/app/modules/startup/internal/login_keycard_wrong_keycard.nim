type
  LoginKeycardWrongKeycardState* = ref object of State

proc newLoginKeycardWrongKeycardState*(flowType: FlowType, backState: State): LoginKeycardWrongKeycardState =
  result = LoginKeycardWrongKeycardState()
  result.setup(flowType, StateType.LoginKeycardWrongKeycard, backState)

proc delete*(self: LoginKeycardWrongKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardWrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()

method getNextSecondaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)