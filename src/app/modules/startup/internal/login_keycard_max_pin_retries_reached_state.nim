type
  LoginKeycardMaxPinRetriesReachedState* = ref object of State

proc newLoginKeycardMaxPinRetriesReachedState*(flowType: FlowType, backState: State): LoginKeycardMaxPinRetriesReachedState =
  result = LoginKeycardMaxPinRetriesReachedState()
  result.setup(flowType, StateType.LoginKeycardMaxPinRetriesReached, backState)

proc delete*(self: LoginKeycardMaxPinRetriesReachedState) =
  self.State.delete

method executeBackCommand*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.AppLogin and controller.isKeycardCreatedAccountSelectedOne():
    controller.runLoginFlow()

method executePrimaryCommand*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()

method getNextPrimaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  return createState(StateType.KeycardRecover, self.flowType, self)

method getNextSecondaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardMaxPinRetriesReachedState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)