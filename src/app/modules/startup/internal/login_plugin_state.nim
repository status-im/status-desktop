type
  LoginPluginState* = ref object of State

proc newLoginPluginState*(flowType: FlowType, backState: State): LoginPluginState =
  result = LoginPluginState()
  result.setup(flowType, StateType.LoginPlugin, backState)

proc delete*(self: LoginPluginState) =
  self.State.delete

method executePrimaryCommand*(self: LoginPluginState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()
    elif not controller.keychainErrorOccurred() and controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextPrimaryState*(self: LoginPluginState, controller: Controller): State =
  if controller.keychainErrorOccurred() or controller.getPin().len != PINLengthForStatusApp:
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextSecondaryState*(self: LoginPluginState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginPluginState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginPluginState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)