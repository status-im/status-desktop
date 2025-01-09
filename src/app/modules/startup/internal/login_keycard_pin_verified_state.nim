type LoginKeycardPinVerifiedState* = ref object of State

proc newLoginKeycardPinVerifiedState*(
    flowType: FlowType, backState: State
): LoginKeycardPinVerifiedState =
  result = LoginKeycardPinVerifiedState()
  result.setup(flowType, StateType.LoginKeycardPinVerified, backState)

proc delete*(self: LoginKeycardPinVerifiedState) =
  self.State.delete

method executePrimaryCommand*(
    self: LoginKeycardPinVerifiedState, controller: Controller
) =
  if self.flowType == FlowType.AppLogin:
    let storeToKeychainValue =
      singletonInstance.localAccountSettings.getStoreToKeychainValue()
    # FIXME: Make sure storeToKeychain is correct here. The idea is not to pass it at all
    # https://github.com/status-im/status-desktop/issues/15167
    controller.loginAccountKeycard(false)
