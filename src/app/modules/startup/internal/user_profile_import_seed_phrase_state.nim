type
  UserProfileImportSeedPhraseState* = ref object of State

proc newUserProfileImportSeedPhraseState*(flowType: FlowType, backState: State): UserProfileImportSeedPhraseState =
  result = UserProfileImportSeedPhraseState()
  result.setup(flowType, StateType.UserProfileImportSeedPhrase, backState)

proc delete*(self: UserProfileImportSeedPhraseState) =
  self.State.delete

method executeBackCommand*(self: UserProfileImportSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.cancelCurrentFlow()

method getNextPrimaryState*(self: UserProfileImportSeedPhraseState, controller: Controller): State =
  return createState(StateType.UserProfileEnterSeedPhrase, FlowType.FirstRunNewUserImportSeedPhrase, self)

method executeSecondaryCommand*(self: UserProfileImportSeedPhraseState, controller: Controller) =
  self.setFlowType(FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard)
  controller.runLoadAccountFlow()

method resolveKeycardNextState*(self: UserProfileImportSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)