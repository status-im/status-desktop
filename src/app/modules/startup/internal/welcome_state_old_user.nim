type WelcomeStateOldUser* = ref object of State

proc newWelcomeStateOldUser*(
    flowType: FlowType, backState: State
): WelcomeStateOldUser =
  result = WelcomeStateOldUser()
  result.setup(flowType, StateType.WelcomeOldStatusUser, backState)

proc delete*(self: WelcomeStateOldUser) =
  self.State.delete

method executeBackCommand*(self: WelcomeStateOldUser, controller: Controller) =
  controller.cancelCurrentFlow()
  if self.stateType != StateType.Welcome and
      controller.isSelectedAccountAKeycardAccount():
    # means we're getting back to login flow
    controller.runLoginFlow()

method getNextPrimaryState*(self: WelcomeStateOldUser, controller: Controller): State =
  return createState(
    StateType.SyncDeviceWithSyncCode, FlowType.FirstRunOldUserSyncCode, self
  )

method getNextSecondaryState*(
    self: WelcomeStateOldUser, controller: Controller
): State =
  return createState(StateType.RecoverOldUser, self.flowType, self)
