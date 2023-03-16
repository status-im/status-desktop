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
  let sp = controller.getSeedPhrase()
  if self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getSelectedKeyPairDto().keyUid
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), sp)
  if self.flowType == FlowType.UnlockKeycard:
    controller.setUnlockUsingSeedPhrase(true)
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    let keyUid = controller.getKeyUidForSeedPhrase(sp)
    self.verifiedSeedPhrase = controller.validSeedPhrase(sp) and keyUid == controller.getKeyPairForProcessing().getKeyUid()
    if not self.verifiedSeedPhrase:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method getNextPrimaryState*(self: WrongSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      if not self.verifiedSeedPhrase:
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))
        return self
  if self.flowType == FlowType.UnlockKeycard:
    if self.verifiedSeedPhrase:
      return createState(StateType.CreatePin, self.flowType, nil)
    return self

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
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setDestinationKeycardUid(keycardEvent.instanceUID)
        controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
        return createState(StateType.CopyingKeycard, self.flowType, nil)
