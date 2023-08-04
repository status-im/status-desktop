type
  ImportSeedPhraseState* = ref object of State

proc newImportSeedPhraseState*(backState: State): ImportSeedPhraseState =
  result = ImportSeedPhraseState()
  result.setup(StateType.ImportSeedPhrase, backState)

proc delete*(self: ImportSeedPhraseState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: ImportSeedPhraseState, controller: Controller) =
  controller.authenticateLoggedInUser()