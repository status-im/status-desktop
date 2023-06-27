type
  ConfirmAddingNewMasterKeyState* = ref object of State

proc newConfirmAddingNewMasterKeyState*(backState: State): ConfirmAddingNewMasterKeyState =
  result = ConfirmAddingNewMasterKeyState()
  result.setup(StateType.ConfirmAddingNewMasterKey, backState)

proc delete*(self: ConfirmAddingNewMasterKeyState) =
  self.State.delete
  
method executePrePrimaryStateCommand*(self: ConfirmAddingNewMasterKeyState, controller: Controller) =
  let seedPhrase = controller.getRandomMnemonic()
  let genAccDto = controller.createAccountFromSeedPhrase(seedPhrase)
  if genAccDto.address.len == 0:
    # should never be here
    error "unable to create an account from the provided seed phrase"
    controller.closeAddAccountPopup()
    return

method getNextPrimaryState*(self: ConfirmAddingNewMasterKeyState, controller: Controller): State =
  return createState(StateType.DisplaySeedPhrase, self)