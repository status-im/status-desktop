type
  LoginKeycardWrongPinState* = ref object of State
    pinValid: bool

proc newLoginKeycardWrongPinState*(flowType: FlowType, backState: State): LoginKeycardWrongPinState =
  result = LoginKeycardWrongPinState()
  result.setup(flowType, StateType.LoginKeycardWrongPin, backState)
  result.pinValid = false

proc delete*(self: LoginKeycardWrongPinState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardWrongPinState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()
    elif controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextSecondaryState*(self: LoginKeycardWrongPinState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardWrongPinState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)
  
method resolveKeycardNextState*(self: LoginKeycardWrongPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceLogin(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return nil
        return createState(StateType.LoginKeycardMaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.LoginKeycardMaxPinRetriesReached, self.flowType, nil)
        return nil
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        controller.loginAccountKeycard()
        return nil