type
  NotificationState* = ref object of State

proc newNotificationState*(flowType: FlowType, backState: State): NotificationState =
  result = NotificationState()
  result.setup(flowType, StateType.AllowNotifications, backState)

proc delete*(self: NotificationState) =
  self.State.delete

method getNextPrimaryState*(self: NotificationState, controller: Controller): State =
  controller.proceedToApp()
