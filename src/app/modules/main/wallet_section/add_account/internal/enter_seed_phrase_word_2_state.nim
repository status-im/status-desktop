type
  EnterSeedPhraseWord2State* = ref object of State

proc newEnterSeedPhraseWord2State*(backState: State): EnterSeedPhraseWord2State =
  result = EnterSeedPhraseWord2State()
  result.setup(StateType.EnterSeedPhraseWord2, backState)

proc delete*(self: EnterSeedPhraseWord2State) =
  self.State.delete
  
method getNextPrimaryState*(self: EnterSeedPhraseWord2State, controller: Controller): State =
  return createState(StateType.ConfirmSeedPhraseBackup, self)