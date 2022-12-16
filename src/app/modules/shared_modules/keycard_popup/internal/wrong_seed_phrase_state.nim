import os

type
  WrongSeedPhraseState* = ref object of State
    verifiedSeedPhrase: bool

proc newWrongSeedPhraseState*(flowType: FlowType, backState: State): WrongSeedPhraseState =
  result = WrongSeedPhraseState()
  result.setup(flowType, StateType.WrongSeedPhrase, backState)
  result.verifiedSeedPhrase = false

proc delete*(self: WrongSeedPhraseState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: WrongSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    sleep(500) # just to shortly remove text on the UI side
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getSelectedKeyPairDto().keyUid
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    sleep(500) # just to shortly remove text on the UI side
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getKeyPairForProcessing().getKeyUid()
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
  if self.flowType == FlowType.UnlockKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    sleep(500) # just to shortly remove text on the UI side
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      controller.getKeyUidForSeedPhrase(controller.getSeedPhrase()) == controller.getKeyPairForProcessing().getKeyUid()
    if self.verifiedSeedPhrase:
      controller.runGetMetadataFlow()
    else:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method executeCancelCommand*(self: WrongSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard:
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
        return createState(StateType.MigratingKeyPair, self.flowType, nil)
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.GetMetadata:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      if keycardFlowType == ResponseTypeValueKeycardFlowResult:
        if keycardEvent.error.len == 0:
          controller.setKeycardUid(keycardEvent.instanceUID)
          controller.runLoadAccountFlow(seedPhraseLength = controller.getSeedPhraseLength(), seedPhrase = controller.getSeedPhrase(), 
            pin = "", puk = "", factoryReset = true)
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.LoadAccount:
      if keycardFlowType == ResponseTypeValueEnterNewPIN and 
        keycardEvent.error.len > 0 and
        keycardEvent.error == ErrorRequireInit:
          return createState(StateType.CreatePin, self.flowType, nil)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setDestinationKeycardUid(keycardEvent.instanceUID)
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
        return createState(StateType.CopyingKeycard, self.flowType, nil)
