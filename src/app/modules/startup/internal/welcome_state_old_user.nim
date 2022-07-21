type
  WelcomeStateOldUser* = ref object of State

proc newWelcomeStateOldUser*(flowType: FlowType, backState: State): WelcomeStateOldUser =
  result = WelcomeStateOldUser()
  result.setup(flowType, StateType.WelcomeOldStatusUser, backState)

proc delete*(self: WelcomeStateOldUser) =
  self.State.delete

method executeBackCommand*(self: WelcomeStateOldUser, controller: Controller) =
  if self.flowType == FlowType.AppLogin and controller.isKeycardCreatedAccountSelectedOne():
    controller.runLoginFlow()

method getNextPrimaryState*(self: WelcomeStateOldUser, controller: Controller): State =
  # We will handle here a click on `Scan sync code`
  discard

method getNextSecondaryState*(self: WelcomeStateOldUser, controller: Controller): State =
  return createState(StateType.KeycardPluginReader, FlowType.FirstRunOldUserKeycardImport, self)  

method getNextTertiaryState*(self: WelcomeStateOldUser, controller: Controller): State =
  return createState(StateType.UserProfileEnterSeedPhrase, FlowType.FirstRunOldUserImportSeedPhrase, self)

