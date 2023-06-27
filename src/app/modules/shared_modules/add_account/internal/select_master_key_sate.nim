type
  SelectMasterKeyState* = ref object of State

proc newSelectMasterKeyState*(backState: State): SelectMasterKeyState =
  result = SelectMasterKeyState()
  result.setup(StateType.SelectMasterKey, backState)

proc delete*(self: SelectMasterKeyState) =
  self.State.delete
  
method getNextPrimaryState*(self: SelectMasterKeyState, controller: Controller): State =
  return createState(StateType.EnterSeedPhrase, self)

method getNextSecondaryState*(self: SelectMasterKeyState, controller: Controller): State =
  return createState(StateType.EnterPrivateKey, self)

method getNextTertiaryState*(self: SelectMasterKeyState, controller: Controller): State =
  return createState(StateType.ConfirmAddingNewMasterKey, self)