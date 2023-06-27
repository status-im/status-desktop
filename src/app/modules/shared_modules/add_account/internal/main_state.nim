type
  MainState* = ref object of State

proc newMainState*(backState: State): MainState =
  result = MainState()
  result.setup(StateType.Main, backState)

proc delete*(self: MainState) =
  self.State.delete
  
method executePrePrimaryStateCommand*(self: MainState, controller: Controller) =
  controller.finalizeAction()

method getNextSecondaryState*(self: MainState, controller: Controller): State =
  return createState(StateType.SelectMasterKey, self)