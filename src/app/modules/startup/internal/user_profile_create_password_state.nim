import state
import ../controller
import user_profile_confirm_password_state

type
  UserProfileCreatePasswordState* = ref object of State

proc newUserProfileCreatePasswordState*(flowType: FlowType, backState: State): UserProfileCreatePasswordState =
  result = UserProfileCreatePasswordState()
  result.setup(flowType, StateType.UserProfileCreatePassword, backState)

proc delete*(self: UserProfileCreatePasswordState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileCreatePasswordState): State =
  return newUserProfileConfirmPasswordState(self.State.flowType, self)

method executeBackCommand*(self: UserProfileCreatePasswordState, controller: Controller) =
  controller.setPassword("")