type
  WelcomeStateNewUser* = ref object of State

proc newWelcomeStateNewUser*(flowType: FlowType, backState: State): WelcomeStateNewUser =
  result = WelcomeStateNewUser()
  result.setup(flowType, StateType.WelcomeNewStatusUser, backState)

proc delete*(self: WelcomeStateNewUser) =
  self.State.delete

method executeBackCommand*(self: WelcomeStateNewUser, controller: Controller) =
  if self.flowType == FlowType.AppLogin and controller.isKeycardCreatedAccountSelectedOne():
    controller.runLoginFlow()

method getNextPrimaryState*(self: WelcomeStateNewUser, controller: Controller): State =
  return createState(StateType.UserProfileCreate, FlowType.FirstRunNewUserNewKeys, self)

method getNextSecondaryState*(self: WelcomeStateNewUser, controller: Controller): State =
  return createState(StateType.KeycardPluginReader, FlowType.FirstRunNewUserNewKeycardKeys, self)

method getNextTertiaryState*(self: WelcomeStateNewUser, controller: Controller): State =
  return createState(StateType.UserProfileImportSeedPhrase, FlowType.General, self)