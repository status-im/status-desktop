import ../../../global/global_singleton

type
  LoginKeycardReadingKeycardState* = ref object of State

proc newLoginKeycardReadingKeycardState*(flowType: FlowType, backState: State): LoginKeycardReadingKeycardState =
  result = LoginKeycardReadingKeycardState()
  result.setup(flowType, StateType.LoginKeycardReadingKeycard, backState)

proc delete*(self: LoginKeycardReadingKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardReadingKeycardState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()
    elif not controller.keychainErrorOccurred() and controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextPrimaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  if controller.keychainErrorOccurred():
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextSecondaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)