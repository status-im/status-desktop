type
  DisplaySeedPhraseState* = ref object of State

proc newDisplaySeedPhraseState*(backState: State): DisplaySeedPhraseState =
  result = DisplaySeedPhraseState()
  result.setup(StateType.DisplaySeedPhrase, backState)

proc delete*(self: DisplaySeedPhraseState) =
  self.State.delete
  
method getNextPrimaryState*(self: DisplaySeedPhraseState, controller: Controller): State =
  return createState(StateType.EnterSeedPhraseWord1, self)