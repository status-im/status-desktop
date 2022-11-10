type
  EnterSeedPhraseState* = ref object of State
    verifiedSeedPhrase: bool

proc newEnterSeedPhraseState*(flowType: FlowType, backState: State): EnterSeedPhraseState =
  result = EnterSeedPhraseState()
  result.setup(flowType, StateType.EnterSeedPhrase, backState)
  result.verifiedSeedPhrase = false

proc delete*(self: EnterSeedPhraseState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: EnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      controller.seedPhraseRefersToSelectedKeyPair(controller.getSeedPhrase())
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
  if self.flowType == FlowType.UnlockKeycard:
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getKeyUidWhichIsBeingUnlocking()
    if self.verifiedSeedPhrase:
      controller.runGetMetadataFlow()
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method getNextPrimaryState*(self: EnterSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.UnlockKeycard:
      if not self.verifiedSeedPhrase:
        return createState(StateType.WrongSeedPhrase, self.flowType, nil)

method executeCancelCommand*(self: EnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.UnlockKeycard:
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
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          controller.setKeycardUid(keycardEvent.instanceUID)
          controller.runLoadAccountFlow(seedPhraseLength = controller.getSeedPhraseLength(), seedPhrase = controller.getSeedPhrase(), puk = "", factoryReset = true)
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.LoadAccount:
      if keycardFlowType == ResponseTypeValueEnterNewPIN and 
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorRequireInit:
          return createState(StateType.CreatePin, self.flowType, nil)
