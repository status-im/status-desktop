type
  UnlockingKeycardState* = ref object of State

proc newUnlockingKeycardState*(flowType: FlowType, backState: State): UnlockingKeycardState =
  result = UnlockingKeycardState()
  result.setup(flowType, StateType.UnlockingKeycard, backState)

proc delete*(self: UnlockingKeycardState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: UnlockingKeycardState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    if controller.unlockUsingSeedPhrase():
      controller.runGetMetadataFlow()
    else:
      let (_, flowEvent) = controller.getLastReceivedKeycardData()
      controller.updateKeycardUid(flowEvent.keyUid, flowEvent.instanceUID)
      
method getNextPrimaryState*(self: UnlockingKeycardState, controller: Controller): State =
  if self.flowType == FlowType.UnlockKeycard:
    if not controller.unlockUsingSeedPhrase():
      return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)

method resolveKeycardNextState*(self: UnlockingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.UnlockKeycard:
    if controller.unlockUsingSeedPhrase():
      if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
        controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
        if keycardFlowType == ResponseTypeValueKeycardFlowResult:
          if keycardEvent.error.len == 0:
            controller.runLoadAccountFlow(controller.getSeedPhraseLength(), controller.getSeedPhrase(), controller.getPin(), puk = "",
              factoryReset = true)
            return
      if controller.getCurrentKeycardServiceFlow() == KCSFlowType.LoadAccount:
        if keycardFlowType == ResponseTypeValueKeycardFlowResult:
          if controller.getKeyPairForProcessing().getKeyUid() != keycardEvent.keyUid:
            error "load account keyUid and keyUid being unlocked do not match"
            controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
            return
          controller.updateKeycardUid(keycardEvent.keyUid, keycardEvent.instanceUID)
          let md = controller.getMetadataFromKeycard()
          let paths = md.walletAccounts.map(a => a.path)
          controller.runStoreMetadataFlow(cardName = md.name, pin = controller.getPin(), walletPaths = paths)
      if controller.getCurrentKeycardServiceFlow() == KCSFlowType.StoreMetadata:
        if keycardFlowType == ResponseTypeValueKeycardFlowResult and
          keycardEvent.instanceUID.len > 0:
            return createState(StateType.UnlockKeycardSuccess, self.flowType, nil)
        return createState(StateType.UnlockKeycardFailure, self.flowType, nil)