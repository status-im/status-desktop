type
  WrongSeedPhraseState* = ref object of State
    verifiedSeedPhrase: bool

proc newWrongSeedPhraseState*(flowType: FlowType, backState: State): WrongSeedPhraseState =
  result = WrongSeedPhraseState()
  result.setup(flowType, StateType.WrongSeedPhrase, backState)
  result.verifiedSeedPhrase = false

proc delete*(self: WrongSeedPhraseState) =
  self.State.delete

method executePreBackStateCommand*(self: WrongSeedPhraseState, controller: Controller) =
  controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))

method executePrePrimaryStateCommand*(self: WrongSeedPhraseState, controller: Controller) =
  controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
  let sp = controller.getSeedPhrase()
  if self.flowType == FlowType.SetupNewKeycard:
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getSelectedKeyPairDto().keyUid
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
  if self.flowType == FlowType.UnlockKeycard:
    controller.setUnlockUsingSeedPhrase(true)
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if not self.verifiedSeedPhrase:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if self.verifiedSeedPhrase:
      let migratingProfile = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
      if migratingProfile:
        return
      controller.authenticateUser()

method getNextPrimaryState*(self: WrongSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromKeycardToApp:
      if not self.verifiedSeedPhrase:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
        return self
      let migratingProfile = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
      if migratingProfile:
        let backState = findBackStateWithTargetedStateType(self, StateType.EnterSeedPhrase)
        return createState(StateType.CreatePassword, self.flowType, backState)
  if self.flowType == FlowType.UnlockKeycard:
    if self.verifiedSeedPhrase:
      return createState(StateType.CreatePin, self.flowType, nil)
    return self

method getNextTertiaryState*(self: WrongSeedPhraseState, controller: Controller): State =
  ## Tertiary action is called after each async action during migration process.
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let migratingProfile = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
    if migratingProfile:
      return
    return createState(StateType.MigratingKeypairToApp, self.flowType, nil)

method executeCancelCommand*(self: WrongSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromKeycardToApp:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.keyUid.len > 0:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
        return createState(StateType.MigratingKeypairToKeycard, self.flowType, nil)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.keyUid.len > 0:
        controller.setDestinationKeycardUid(keycardEvent.instanceUID)
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
        return createState(StateType.CopyingKeycard, self.flowType, nil)
