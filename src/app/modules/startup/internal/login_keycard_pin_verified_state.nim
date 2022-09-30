type
  LoginKeycardPinVerifiedState* = ref object of State

proc newLoginKeycardPinVerifiedState*(flowType: FlowType, backState: State): LoginKeycardPinVerifiedState =
  result = LoginKeycardPinVerifiedState()
  result.setup(flowType, StateType.LoginKeycardPinVerified, backState)

proc delete*(self: LoginKeycardPinVerifiedState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardPinVerifiedState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.loginAccountKeycard()