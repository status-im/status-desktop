type
  UserProfileCreateState* = ref object of State

proc newUserProfileCreateState*(flowType: FlowType, backState: State): UserProfileCreateState =
  result = UserProfileCreateState()
  result.setup(flowType, StateType.UserProfileCreate, backState)

proc delete*(self: UserProfileCreateState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileCreateState, controller: Controller): State =
  return createState(StateType.UserProfileChatKey, self.flowType, self)

method executeBackCommand*(self: UserProfileCreateState, controller: Controller) =
  controller.setDisplayName("")