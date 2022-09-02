type
  KeycardEnterSeedPhraseWordsState* = ref object of State

proc newKeycardEnterSeedPhraseWordsState*(flowType: FlowType, backState: State): KeycardEnterSeedPhraseWordsState =
  result = KeycardEnterSeedPhraseWordsState()
  result.setup(flowType, StateType.KeycardEnterSeedPhraseWords, backState)

proc delete*(self: KeycardEnterSeedPhraseWordsState) =
  self.State.delete

method executeBackCommand*(self: KeycardEnterSeedPhraseWordsState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method executePrimaryCommand*(self: KeycardEnterSeedPhraseWordsState, controller: Controller) =
  controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())

method resolveKeycardNextState*(self: KeycardEnterSeedPhraseWordsState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceOnboarding(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeyUid(keycardEvent.keyUid)
        return createState(StateType.UserProfileCreate, self.flowType, self)