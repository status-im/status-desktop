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

method executePrimaryCommand*(self: WrongSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
    sleep(500) # just to shortly remove text on the UI side
    self.verifiedSeedPhrase = controller.validSeedPhrase(controller.getSeedPhrase()) and
      controller.seedPhraseRefersToSelectedKeyPair(controller.getSeedPhrase())
    if self.verifiedSeedPhrase:
      controller.storeSeedPhraseToKeycard(controller.getSeedPhraseLength(), controller.getSeedPhrase())
    else:
      controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = true))

method executeSecondaryCommand*(self: WrongSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.keyUid.len > 0:
        controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WrongSeedPhrase, add = false))
        return createState(StateType.MigratingKeyPair, self.flowType, nil)
