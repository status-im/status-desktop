import state
import user_profile_create_password_state

type
  UserProfileChatKeyState* = ref object of State

proc newUserProfileChatKeyState*(flowType: FlowType, backState: State): UserProfileChatKeyState =
  result = UserProfileChatKeyState()
  result.setup(flowType, StateType.UserProfileChatKey, backState)

proc delete*(self: UserProfileChatKeyState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileChatKeyState): State =
  return newUserProfileCreatePasswordState(self.State.flowType, self)
