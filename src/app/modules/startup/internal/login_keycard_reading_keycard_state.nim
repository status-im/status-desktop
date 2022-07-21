import ../../../global/global_singleton

type
  LoginKeycardReadingKeycardState* = ref object of State

proc newLoginKeycardReadingKeycardState*(flowType: FlowType, backState: State): LoginKeycardReadingKeycardState =
  result = LoginKeycardReadingKeycardState()
  result.setup(flowType, StateType.LoginKeycardReadingKeycard, backState)

proc delete*(self: LoginKeycardReadingKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardReadingKeycardState, controller: Controller) =
  if not controller.keychainErrorOccurred():
    controller.enterKeycardPin(controller.getPin())

method getNextPrimaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  if controller.keychainErrorOccurred():
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextSecondaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        controller.setKeycardEvent(keycardEvent)
        controller.loginAccountKeycard()
        return nil
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len == 0:
        if not controller.keyUidMatch(keycardEvent.keyUid):
          return createState(StateType.LoginKeycardWrongKeycard, self.flowType, nil)
        let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
        if value == LS_VALUE_STORE:
          controller.tryToObtainDataFromKeychain()
          return nil
        return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.LoginKeycardMaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorNoKeys:
        return createState(StateType.LoginKeycardEmpty, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueSwapCard and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUKRetries:
        return createState(StateType.LoginKeycardMaxPukRetriesReached, self.flowType, nil)