type
  LoginKeycardEnterPinState* = ref object of State

proc newLoginKeycardEnterPinState*(flowType: FlowType, backState: State): LoginKeycardEnterPinState =
  result = LoginKeycardEnterPinState()
  result.setup(flowType, StateType.LoginKeycardEnterPin, backState)

proc delete*(self: LoginKeycardEnterPinState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardEnterPinState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextSecondaryState*(self: LoginKeycardEnterPinState, controller: Controller): State =
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardEnterPinState, controller: Controller): State =
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardEnterPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        controller.loginAccountKeycard()
        return nil
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return createState(StateType.LoginKeycardWrongPin, self.flowType, nil)
        return createState(StateType.LoginKeycardMaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.LoginKeycardMaxPinRetriesReached, self.flowType, nil)