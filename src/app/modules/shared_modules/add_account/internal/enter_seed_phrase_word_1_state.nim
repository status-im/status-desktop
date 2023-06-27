type
  EnterSeedPhraseWord1State* = ref object of State

proc newEnterSeedPhraseWord1State*(backState: State): EnterSeedPhraseWord1State =
  result = EnterSeedPhraseWord1State()
  result.setup(StateType.EnterSeedPhraseWord1, backState)

proc delete*(self: EnterSeedPhraseWord1State) =
  self.State.delete
  
method getNextPrimaryState*(self: EnterSeedPhraseWord1State, controller: Controller): State =
  return createState(StateType.EnterSeedPhraseWord2, self)