type
  LoginKeycardInsertKeycardState* = ref object of State

proc newLoginKeycardInsertKeycardState*(flowType: FlowType, backState: State): LoginKeycardInsertKeycardState =
  result = LoginKeycardInsertKeycardState()
  result.setup(flowType, StateType.LoginKeycardInsertKeycard, backState)

proc delete*(self: LoginKeycardInsertKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardInsertKeycardState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()
    elif not controller.keychainErrorOccurred() and controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextPrimaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  if controller.keychainErrorOccurred() or controller.getPin().len != PINLengthForStatusApp:
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextSecondaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardInsertKeycardState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardInsertKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceLogin(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.setKeycardData(ResponseTypeValueInsertCard)
      return nil
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData("")
    return createState(StateType.LoginKeycardReadingKeycard, self.flowType, nil)
  return nil