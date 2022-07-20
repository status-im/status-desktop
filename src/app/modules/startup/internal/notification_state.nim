import state, welcome_state

type
  NotificationState* = ref object of State

proc newNotificationState*(flowType: FlowType, backState: State): NotificationState =
  result = NotificationState()
  result.setup(flowType, StateType.AllowNotifications, backState)

proc delete*(self: NotificationState) =
  self.State.delete

method getNextPrimaryState*(self: NotificationState): State =
  return newWelcomeState(FlowType.General, nil)
