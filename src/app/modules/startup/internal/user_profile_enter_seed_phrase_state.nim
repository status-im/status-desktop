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
    if self.enteredMnemonicMatchTargetedKeyUid:
      return createState(StateType.KeycardCreatePin, self.flowType, self)
    let backState = findBackStateWithTargetedStateType(self, StateType.RecoverOldUser)
    return createState(StateType.KeycardWrongKeycard, self.flowType, backState)
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
    return createState(StateType.UserProfileCreatePassword, self.flowType, self)
  if self.flowType == FlowType.AppLogin:
    if self.enteredMnemonicMatchTargetedKeyUid:
      return createState(StateType.KeycardCreatePin, self.flowType, self)
    return createState(StateType.KeycardWrongKeycard, self.flowType, self)
  if self.flowType == FlowType.LostKeycardReplacement:
    if self.enteredMnemonicMatchTargetedKeyUid:
      return createState(StateType.KeycardCreatePin, self.flowType, self)
    return createState(StateType.UserProfileWrongSeedPhrase, self.flowType, self)
  if self.flowType == FlowType.LostKeycardConvertToRegularAccount:
    if self.enteredMnemonicMatchTargetedKeyUid:
      return createState(StateType.UserProfileCreatePassword, self.flowType, self)
    return createState(StateType.UserProfileWrongSeedPhrase, self.flowType, self)

method executePrimaryCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunOldUserImportSeedPhrase:
      self.successfulImport = controller.importMnemonic()
  else:
    self.successfulImport = controller.validMnemonic(controller.getSeedPhrase())
    if self.successfulImport:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
      let keyUid = controller.getKeyUidForSeedPhrase(controller.getSeedPhrase())

      if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
        controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
      if self.flowType == FlowType.FirstRunOldUserKeycardImport:
        self.enteredMnemonicMatchTargetedKeyUid = keyUid == controller.getKeyUid()
        if not self.enteredMnemonicMatchTargetedKeyUid:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))  
      if self.flowType == FlowType.AppLogin:
        self.enteredMnemonicMatchTargetedKeyUid = controller.keyUidMatchSelectedLoginAccount(keyUid)
        if not self.enteredMnemonicMatchTargetedKeyUid:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
      if self.flowType == FlowType.LostKeycardReplacement:
        self.enteredMnemonicMatchTargetedKeyUid = controller.keyUidMatchSelectedLoginAccount(keyUid)
        if self.enteredMnemonicMatchTargetedKeyUid:
          controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
        else:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
      if self.flowType == FlowType.LostKeycardConvertToRegularAccount:
        self.enteredMnemonicMatchTargetedKeyUid = controller.keyUidMatchSelectedLoginAccount(keyUid)
        if not self.enteredMnemonicMatchTargetedKeyUid:
          controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method resolveKeycardNextState*(self: UserProfileEnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)