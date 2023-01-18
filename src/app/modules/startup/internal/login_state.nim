type
  LoginState* = ref object of State

proc newLoginState*(flowType: FlowType, backState: State): LoginState =
  result = LoginState()
  result.setup(flowType, StateType.Login, backState)

proc delete*(self: LoginState) =
  self.State.delete

method executePrimaryCommand*(self: LoginState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if controller.keychainErrorOccurred():
      return
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()
    elif controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextSecondaryState*(self: LoginState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      return createState(StateType.LoginKeycardEnterPassword, self.flowType, nil)
    else:
      return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextTertiaryState*(self: LoginState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(self: LoginState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(self: LoginState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(self: LoginState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)