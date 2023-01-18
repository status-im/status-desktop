type
  UserProfileEnterSeedPhraseState* = ref object of State
    successfulImport: bool
    enteredMnemonicMatchTargetedKeyUid: bool

proc newUserProfileEnterSeedPhraseState*(flowType: FlowType, backState: State): UserProfileEnterSeedPhraseState =
  result = UserProfileEnterSeedPhraseState()
  result.setup(flowType, StateType.UserProfileEnterSeedPhrase, backState)
  result.successfulImport = false
  result.enteredMnemonicMatchTargetedKeyUid = false

proc delete*(self: UserProfileEnterSeedPhraseState) =
  self.State.delete

method executeBackCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.cancelCurrentFlow()

method getNextPrimaryState*(self: UserProfileEnterSeedPhraseState, controller: Controller): State =
  if not self.successfulImport:
    return nil
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    return createState(StateType.UserProfileCreate, self.flowType, self)
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if not self.enteredMnemonicMatchTargetedKeyUid:
      return createState(StateType.KeycardWrongKeycard, self.flowType, nil)
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    return createState(StateType.UserProfileCreatePassword, self.flowType, self)

method executePrimaryCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    self.successfulImport = controller.validMnemonic(controller.getSeedPhrase()) and
      controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getSelectedLoginAccount().keyUid
    if self.successfulImport:
      controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), pin = "", puk = "", 
        factoryReset = true)
  else:
    if self.flowType == FlowType.FirstRunNewUserImportSeedPhrase or
      self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
        self.successfulImport = controller.importMnemonic()
    else:
      self.successfulImport = controller.validMnemonic(controller.getSeedPhrase())
      if self.successfulImport:
        if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
          controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
        if self.flowType == FlowType.FirstRunOldUserKeycardImport:
          self.enteredMnemonicMatchTargetedKeyUid = controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getKeyUid()
          if self.enteredMnemonicMatchTargetedKeyUid:
            controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), pin = "", puk = "",
              factoryReset = true)
        if self.flowType == FlowType.LostKeycardReplacement:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
          let keyUid = controller.getKeyUidForSeedPhrase(controller.getSeedPhrase())
          self.enteredMnemonicMatchTargetedKeyUid = controller.keyUidMatchSelectedLoginAccount(keyUid)
          if self.enteredMnemonicMatchTargetedKeyUid:
            controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
          else:
            controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method resolveKeycardNextState*(self: UserProfileEnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)