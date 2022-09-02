type
  UserProfileEnterSeedPhraseState* = ref object of State
    successfulImport: bool

proc newUserProfileEnterSeedPhraseState*(flowType: FlowType, backState: State): UserProfileEnterSeedPhraseState =
  result = UserProfileEnterSeedPhraseState()
  result.setup(flowType, StateType.UserProfileEnterSeedPhrase, backState)
  result.successfulImport = false

proc delete*(self: UserProfileEnterSeedPhraseState) =
  self.State.delete

method executeBackCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.cancelCurrentFlow()

method getNextPrimaryState*(self: UserProfileEnterSeedPhraseState, controller: Controller): State =
  if not self.successfulImport:
    return nil
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    return createState(StateType.UserProfileCreate, self.flowType, self)

method executePrimaryCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlowWithSeedPhrase(controller.getSeedPhraseLength(), controller.getSeedPhrase(), factoryReset = true)
  else:
    self.successfulImport = controller.importMnemonic()
    if self.successfulImport:
      if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
        controller.runLoadAccountFlowWithSeedPhrase(controller.getSeedPhraseLength(), controller.getSeedPhrase(), factoryReset = true)
      elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
        controller.runLoadAccountFlowWithSeedPhrase(controller.getSeedPhraseLength(), controller.getSeedPhrase(), factoryReset = true)

method resolveKeycardNextState*(self: UserProfileEnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)