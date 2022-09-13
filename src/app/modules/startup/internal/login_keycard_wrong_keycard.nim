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
    elif not controller.keychainErrorOccurred() and controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextPrimaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  if controller.keychainErrorOccurred():
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextSecondaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardWrongKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardWrongKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)