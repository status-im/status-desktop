type
  UserProfileCreatePasswordState* = ref object of State

proc newUserProfileCreatePasswordState*(flowType: FlowType, backState: State): UserProfileCreatePasswordState =
  result = UserProfileCreatePasswordState()
  result.setup(flowType, StateType.UserProfileCreatePassword, backState)

proc delete*(self: UserProfileCreatePasswordState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileCreatePasswordState, controller: Controller): State =
  return createState(StateType.UserProfileConfirmPassword, self.flowType, self)

method executeBackCommand*(self: UserProfileCreatePasswordState, controller: Controller) =
  controller.setPassword("")