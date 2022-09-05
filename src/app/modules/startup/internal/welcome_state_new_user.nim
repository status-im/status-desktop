type
  WelcomeStateNewUser* = ref object of State

proc newWelcomeStateNewUser*(flowType: FlowType, backState: State): WelcomeStateNewUser =
  result = WelcomeStateNewUser()
  result.setup(flowType, StateType.WelcomeNewStatusUser, backState)

proc delete*(self: WelcomeStateNewUser) =
  self.State.delete

method executeBackCommand*(self: WelcomeStateNewUser, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.cancelCurrentFlow()
  elif self.flowType == FlowType.AppLogin and controller.isKeycardCreatedAccountSelectedOne():
    controller.runLoginFlow()

method executeSecondaryCommand*(self: WelcomeStateNewUser, controller: Controller) =
  self.setFlowType(FlowType.FirstRunNewUserNewKeycardKeys)
  controller.runLoadAccountFlow()
  
method getNextPrimaryState*(self: WelcomeStateNewUser, controller: Controller): State =
  return createState(StateType.UserProfileCreate, FlowType.FirstRunNewUserNewKeys, self)

method getNextTertiaryState*(self: WelcomeStateNewUser, controller: Controller): State =
  return createState(StateType.UserProfileImportSeedPhrase, FlowType.General, self)

method resolveKeycardNextState*(self: WelcomeStateNewUser, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)