import state
import ../controller
import welcome_state_new_user, welcome_state_old_user

type
  LoginState* = ref object of State

proc newLoginState*(flowType: FlowType, backState: State): LoginState =
  result = LoginState()
  result.setup(flowType, StateType.Login, backState)

proc delete*(self: LoginState) =
  self.State.delete

method moveToNextPrimaryState*(self: LoginState): bool =
  return false

method executePrimaryCommand*(self: LoginState, controller: Controller) =
  controller.login()

method getNextSecondaryState*(self: LoginState): State =
  return newWelcomeStateNewUser(FlowType.General, self)

method getNextTertiaryState*(self: LoginState): State =
  return newWelcomeStateOldUser(FlowType.General, self)