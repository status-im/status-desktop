type
  EnterSeedPhraseState* = ref object of State
    verifiedSeedPhrase: bool
    keyPairAlreadyMigrated: bool
    keyPairAlreadyAdded: bool

proc newEnterSeedPhraseState*(flowType: FlowType, backState: State): EnterSeedPhraseState =
  result = EnterSeedPhraseState()
  result.setup(flowType, StateType.EnterSeedPhrase, backState)
  result.verifiedSeedPhrase = false
  result.keyPairAlreadyMigrated = false
  result.keyPairAlreadyAdded = false

proc delete*(self: EnterSeedPhraseState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: EnterSeedPhraseState, controller: Controller) =
  let sp = controller.getSeedPhrase()
  if self.flowType == FlowType.SetupNewKeycard:
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getSelectedKeyPairDto().keyUid
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp)
    if self.verifiedSeedPhrase:
      ## should always be true, since it's not possible to do primary command otherwise (button is disabled on the UI)
      let keyUid = controller.getKeyUidForSeedPhrase(sp)
      self.keyPairAlreadyMigrated = controller.getKeycardsWithSameKeyUid(keyUid).len > 0
      if self.keyPairAlreadyMigrated:
        controller.prepareKeyPairForProcessing(keyUid)
        return
      self.keyPairAlreadyAdded = controller.isKeyPairAlreadyAdded(keyUid)
      if self.keyPairAlreadyAdded:
        controller.prepareKeyPairForProcessing(keyUid)
        return
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
  if self.flowType == FlowType.UnlockKeycard:
    controller.setUnlockUsingSeedPhrase(true)
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if not self.verifiedSeedPhrase:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method getNextPrimaryState*(self: EnterSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.verifiedSeedPhrase:
      return createState(StateType.WrongSeedPhrase, self.flowType, nil)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if not self.verifiedSeedPhrase:
      return createState(StateType.WrongSeedPhrase, self.flowType, self.getBackState)
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    if not self.verifiedSeedPhrase:
      ## we should never be here
      return createState(StateType.WrongSeedPhrase, self.flowType, self.getBackState)
    if self.keyPairAlreadyMigrated or self.keyPairAlreadyAdded:
      ## Maybe we should differ among these 2 states (keyPairAlreadyMigrated or keyPairAlreadyAdded)
      ## but we need to check that with designers.
      return createState(StateType.SeedPhraseAlreadyInUse, self.flowType, self)
  if self.flowType == FlowType.UnlockKeycard:
    if self.verifiedSeedPhrase:
      return createState(StateType.CreatePin, self.flowType, nil)
    return createState(StateType.WrongSeedPhrase, self.flowType, nil)

method executeCancelCommand*(self: EnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: EnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.keyUid.len > 0:
        return createState(StateType.MigratingKeyPair, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorRequireInit:
        return createState(StateType.CreatePin, self.flowType, nil)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.keyUid.len > 0:
        controller.setDestinationKeycardUid(keycardEvent.instanceUID)
        return createState(StateType.CopyingKeycard, self.flowType, nil)
