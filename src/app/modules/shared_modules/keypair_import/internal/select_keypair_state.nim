type
  SelectKeypairState* = ref object of State

proc newSelectKeypairState*(backState: State): SelectKeypairState =
  result = SelectKeypairState()
  result.setup(StateType.SelectKeypair, backState)

proc delete*(self: SelectKeypairState) =
  self.State.delete

method executePreBackStateCommand*(self: SelectKeypairState, controller: Controller) =
  controller.clearSelectedKeypair()

method getNextPrimaryState*(self: SelectKeypairState, controller: Controller): State =
  return createState(StateType.SelectImportMethod, self)

method getNextSecondaryState*(self: SelectKeypairState, controller: Controller): State =
  return createState(StateType.ImportQr, self)