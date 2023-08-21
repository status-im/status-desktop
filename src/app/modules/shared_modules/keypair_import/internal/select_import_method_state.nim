type
  SelectImportMethodState* = ref object of State

proc newSelectImportMethodState*(backState: State): SelectImportMethodState =
  result = SelectImportMethodState()
  result.setup(StateType.SelectImportMethod, backState)

proc delete*(self: SelectImportMethodState) =
  self.State.delete

method executePreBackStateCommand*(self: SelectImportMethodState, controller: Controller) =
  controller.clearSelectedKeypair()

method getNextPrimaryState*(self: SelectImportMethodState, controller: Controller): State =
  return createState(StateType.ImportQr, self)

method getNextSecondaryState*(self: SelectImportMethodState, controller: Controller): State =
  let kp = controller.getSelectedKeypair()
  if kp.getPairType() == KeyPairType.SeedImport.int:
    return createState(StateType.ImportSeedPhrase, self)
  if kp.getPairType() == KeyPairType.PrivateKeyImport.int:
    return createState(StateType.ImportPrivateKey, self)
  error "ki_unsupported keypair type"