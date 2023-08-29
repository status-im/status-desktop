import strutils

type
  SeedPhraseEnterWordsState* = ref object of State

proc newSeedPhraseEnterWordsState*(flowType: FlowType, backState: State): SeedPhraseEnterWordsState =
  result = SeedPhraseEnterWordsState()
  result.setup(flowType, StateType.SeedPhraseEnterWords, backState)

proc delete*(self: SeedPhraseEnterWordsState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: SeedPhraseEnterWordsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    let mnemonic = controller.getProfileMnemonic()
    controller.setSeedPhrase(mnemonic)
    controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
  elif self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())

method executeCancelCommand*(self: SeedPhraseEnterWordsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: SeedPhraseEnterWordsState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.keyUid.len > 0:
        controller.removeProfileMnemonic()
        return createState(StateType.MigratingKeypairToKeycard, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and
      keycardEvent.keyUid.len > 0:
        controller.setKeycardUid(keycardEvent.instanceUID)
        var item = newKeyPairItem(keyUid = keycardEvent.keyUid)
        item.setIcon("keycard")
        item.setPairType(KeyPairType.SeedImport.int)
        item.addAccount(newKeyPairAccountItem())
        controller.setKeyPairForProcessing(item)
        return createState(StateType.EnterKeycardName, self.flowType, nil)