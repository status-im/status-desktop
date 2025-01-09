type UserProfileChatKeyState* = ref object of State

proc newUserProfileChatKeyState*(
    flowType: FlowType, backState: State
): UserProfileChatKeyState =
  result = UserProfileChatKeyState()
  result.setup(flowType, StateType.UserProfileChatKey, backState)

proc delete*(self: UserProfileChatKeyState) =
  self.State.delete

method executePrimaryCommand*(self: UserProfileChatKeyState, controller: Controller) =
  if not controller.notificationsNeedsEnable():
    controller.proceedToApp()

method getNextPrimaryState*(
    self: UserProfileChatKeyState, controller: Controller
): State =
  if controller.notificationsNeedsEnable():
    return createState(StateType.AllowNotifications, self.flowType, nil)
  return nil
