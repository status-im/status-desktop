type
  KeycardDisplaySeedPhraseState* = ref object of State

proc newKeycardDisplaySeedPhraseState*(flowType: FlowType, backState: State): KeycardDisplaySeedPhraseState =
  result = KeycardDisplaySeedPhraseState()
  result.setup(flowType, StateType.KeycardDisplaySeedPhrase, backState)

proc delete*(self: KeycardDisplaySeedPhraseState) =
  self.State.delete

method executeBackCommand*(self: KeycardDisplaySeedPhraseState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method getNextPrimaryState*(self: KeycardDisplaySeedPhraseState, controller: Controller): State =
  return createState(StateType.KeycardEnterSeedPhraseWords, self.flowType, self.getBackState)