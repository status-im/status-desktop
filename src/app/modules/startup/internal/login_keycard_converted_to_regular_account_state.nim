type
  LoginKeycardConvertedToRegularAccountState* = ref object of State

proc newLoginKeycardConvertedToRegularAccountState*(flowType: FlowType, backState: State): LoginKeycardConvertedToRegularAccountState =
  result = LoginKeycardConvertedToRegularAccountState()
  result.setup(flowType, StateType.LoginKeycardConvertedToRegularAccount, backState)

proc delete*(self: LoginKeycardConvertedToRegularAccountState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardConvertedToRegularAccountState, controller: Controller) =
  if self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    info "restart the app because of successfully converted keycard account to regular account"
    quit() # quit the app