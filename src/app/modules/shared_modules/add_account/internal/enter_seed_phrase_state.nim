type
  EnterSeedPhraseState* = ref object of State

proc newEnterSeedPhraseState*(backState: State): EnterSeedPhraseState =
  result = EnterSeedPhraseState()
  result.setup(StateType.EnterSeedPhrase, backState)

proc delete*(self: EnterSeedPhraseState) =
  self.State.delete
  
method executePrePrimaryStateCommand*(self: EnterSeedPhraseState, controller: Controller) =
  controller.buildNewSeedPhraseKeypairAndAddItToOrigin()

method getNextPrimaryState*(self: EnterSeedPhraseState, controller: Controller): State =
  return createState(StateType.Main, nil)