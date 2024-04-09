type
  NotificationState* = ref object of State

proc newNotificationState*(flowType: FlowType, backState: State): NotificationState =
  result = NotificationState()
  result.setup(flowType, StateType.AllowNotifications, backState)

proc delete*(self: NotificationState) =
  self.State.delete

method getNextPrimaryState*(self: NotificationState, controller: Controller): State =
  # WARNING: Simply always proceed to App?

  if self.flowType == FlowType.FirstRunNewUserNewKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserKeycardImport or
    self.flowType == FLowType.FirstRunNewUserNewKeycardKeys:
      controller.proceedToApp()
  # return createState(StateType.Welcome, FlowType.General, nil)
