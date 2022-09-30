type
  LoginKeycardRecognizedKeycardState* = ref object of State

proc newLoginKeycardRecognizedKeycardState*(flowType: FlowType, backState: State): LoginKeycardRecognizedKeycardState =
  result = LoginKeycardRecognizedKeycardState()
  result.setup(flowType, StateType.LoginKeycardRecognizedKeycard, backState)

proc delete*(self: LoginKeycardRecognizedKeycardState) =
  self.State.delete

method getNextPrimaryState*(self: LoginKeycardRecognizedKeycardState, controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
    if value == LS_VALUE_STORE:
      controller.tryToObtainDataFromKeychain()
      return createState(StateType.Login, self.flowType, nil)
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)
