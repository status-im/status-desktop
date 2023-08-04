type
  ImportPrivateKeyState* = ref object of State

proc newImportPrivateKeyState*(backState: State): ImportPrivateKeyState =
  result = ImportPrivateKeyState()
  result.setup(StateType.ImportPrivateKey, backState)

proc delete*(self: ImportPrivateKeyState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ImportPrivateKeyState, controller: Controller) =
  controller.authenticateLoggedInUser()