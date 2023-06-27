type
  ConfirmSeedPhraseBackupState* = ref object of State

proc newConfirmSeedPhraseBackupState*(backState: State): ConfirmSeedPhraseBackupState =
  result = ConfirmSeedPhraseBackupState()
  result.setup(StateType.ConfirmSeedPhraseBackup, backState)

proc delete*(self: ConfirmSeedPhraseBackupState) =
  self.State.delete
  
method getNextPrimaryState*(self: ConfirmSeedPhraseBackupState, controller: Controller): State =
  return createState(StateType.EnterKeypairName, self)