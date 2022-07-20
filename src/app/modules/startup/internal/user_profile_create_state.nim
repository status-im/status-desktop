import state
import ../controller
import user_profile_chat_key_state

type
  UserProfileCreateState* = ref object of State

proc newUserProfileCreateState*(flowType: FlowType, backState: State): UserProfileCreateState =
  result = UserProfileCreateState()
  result.setup(flowType, StateType.UserProfileCreate, backState)

proc delete*(self: UserProfileCreateState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileCreateState): State =
  return newUserProfileChatKeyState(self.State.flowType, self)

method executeBackCommand*(self: UserProfileCreateState, controller: Controller) =
  controller.setDisplayName("")