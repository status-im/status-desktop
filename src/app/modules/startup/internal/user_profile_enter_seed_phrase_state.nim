type
  UserProfileEnterSeedPhraseState* = ref object of State
    successfulImport: bool

proc newUserProfileEnterSeedPhraseState*(flowType: FlowType, backState: State): UserProfileEnterSeedPhraseState =
  result = UserProfileEnterSeedPhraseState()
  result.setup(flowType, StateType.UserProfileEnterSeedPhrase, backState)
  result.successfulImport = false

proc delete*(self: UserProfileEnterSeedPhraseState) =
  self.State.delete

method getNextPrimaryState*(self: UserProfileEnterSeedPhraseState, controller: Controller): State =
  if not self.successfulImport:
    return nil
  if self.flowType == FlowType.FirstRunOldUserImportSeedPhrase or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhrase:
    return createState(StateType.UserProfileCreate, self.flowType, self)

method executePrimaryCommand*(self: UserProfileEnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlowWithSeedPhrase(controller.getSeedPhraseLength(), controller.getSeedPhrase(), true)
  else:
    self.successfulImport = controller.importMnemonic()
    if self.successfulImport:
      if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
        controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
      elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
        controller.runLoadAccountFlowWithSeedPhrase(controller.getSeedPhraseLength(), controller.getSeedPhrase(), true)

method resolveKeycardNextState*(self: UserProfileEnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, self.flowType, self)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, self.flowType, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, self.flowType, self)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, self.flowType, self.getBackState)
