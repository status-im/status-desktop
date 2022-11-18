type
  UserProfileEnterSeedPhraseState* = ref object of State
    successfulImport: bool
    correctKeycard: bool

proc newUserProfileEnterSeedPhraseState*(flowType: FlowType, backState: State): UserProfileEnterSeedPhraseState =
  result = UserProfileEnterSeedPhraseState()
  result.setup(flowType, StateType.UserProfileEnterSeedPhrase, backState)
  result.successfulImport = false
  result.correctKeycard = false

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
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if not self.correctKeycard:
      return createState(StateType.KeycardWrongKeycard, self.flowType, nil)

method executePrimaryCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    self.successfulImport = controller.validMnemonic(controller.getSeedPhrase()) and
      controller.seedPhraseRefersToSelectedKeyPair(controller.getSeedPhrase())
    if self.successfulImport:
      controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), pin = "", puk = "", 
        factoryReset = true)
  else:
    if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
      self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
      self.successfulImport = controller.importMnemonic()
    else:
      self.successfulImport = controller.validMnemonic(controller.getSeedPhrase())
      if self.successfulImport:
        if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
          controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
        if self.flowType == FlowType.FirstRunOldUserKeycardImport:
          self.correctKeycard = controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getKeyUid()
          if self.correctKeycard:
            controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), pin = "", puk = "",
              factoryReset = true)

method resolveKeycardNextState*(self: UserProfileEnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)