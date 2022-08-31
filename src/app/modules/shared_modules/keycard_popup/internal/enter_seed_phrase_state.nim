type
  EnterSeedPhraseState* = ref object of State
    verifiedSeedPhrase: bool

proc newEnterSeedPhraseState*(flowType: FlowType, backState: State): EnterSeedPhraseState =
  result = EnterSeedPhraseState()
  result.setup(flowType, StateType.EnterSeedPhrase, backState)
  result.verifiedSeedPhrase = false

proc delete*(self: EnterSeedPhraseState) =
  self.State.delete

method executePrimaryCommand*(self: EnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      (not controller.getSelectedKeyPairIsProfile() or
      controller.getSelectedKeyPairIsProfile() and 
      controller.seedPhraseRefersToLoggedInUser(controller.getSeedPhrase()))
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
    else:
      controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method executeSecondaryCommand*(self: EnterSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextPrimaryState*(self: EnterSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.verifiedSeedPhrase:
      return createState(StateType.WrongSeedPhrase, self.flowType, nil)

method resolveKeycardNextState*(self: EnterSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeyUid(keycardEvent.keyUid)
        return createState(StateType.MigratingKeyPair, self.flowType, nil)
