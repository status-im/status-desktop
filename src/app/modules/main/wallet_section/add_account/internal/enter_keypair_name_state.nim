type
  EnterKeypairNameState* = ref object of State

proc newEnterKeypairNameState*(backState: State): EnterKeypairNameState =
  result = EnterKeypairNameState()
  result.setup(StateType.EnterKeypairName, backState)

proc delete*(self: EnterKeypairNameState) =
  self.State.delete
  
method executePrePrimaryStateCommand*(self: EnterKeypairNameState, controller: Controller) =
  controller.buildNewSeedPhraseKeypairAndAddItToOrigin()

method getNextPrimaryState*(self: EnterKeypairNameState, controller: Controller): State =
  return createState(StateType.Main, nil)