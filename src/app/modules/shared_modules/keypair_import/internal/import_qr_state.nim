type
  ImportQrState* = ref object of State

proc newImportQrState*(backState: State): ImportQrState =
  result = ImportQrState()
  result.setup(StateType.ImportQr, backState)

proc delete*(self: ImportQrState) =
  self.State.delete

method executePreBackStateCommand*(self: ImportQrState, controller: Controller) =
  controller.setConnectionString("")

method getNextPrimaryState*(self: ImportQrState, controller: Controller): State =
  controller.authenticateLoggedInUser()

method executePreSecondaryStateCommand*(self: ImportQrState, controller: Controller) =
  controller.setConnectionString("")

method getNextSecondaryState*(self: ImportQrState, controller: Controller): State =
  return createState(StateType.DisplayInstructions, self)