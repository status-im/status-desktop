import strutils

type
  SeedPhraseEnterWordsState* = ref object of State

proc newSeedPhraseEnterWordsState*(flowType: FlowType, backState: State): SeedPhraseEnterWordsState =
  result = SeedPhraseEnterWordsState()
  result.setup(flowType, StateType.SeedPhraseEnterWords, backState)

proc delete*(self: SeedPhraseEnterWordsState) =
  self.State.delete

method executePrimaryCommand*(self: SeedPhraseEnterWordsState, controller: Controller) =
  let mnemonic = controller.getMnemonic()
  controller.setSeedPhrase(mnemonic)
  controller.storeSeedPhraseToKeycard(mnemonic.split(" ").len, mnemonic)

method executeTertiaryCommand*(self: SeedPhraseEnterWordsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: SeedPhraseEnterWordsState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.removeMnemonic()
        return createState(StateType.MigratingKeyPair, self.flowType, nil)