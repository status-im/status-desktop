type
  KeyPairMigrateSuccessState* = ref object of State

proc newKeyPairMigrateSuccessState*(flowType: FlowType, backState: State): KeyPairMigrateSuccessState =
  result = KeyPairMigrateSuccessState()
  result.setup(flowType, StateType.KeyPairMigrateSuccess, backState)

proc delete*(self: KeyPairMigrateSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeyPairMigrateSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    let profileMigrated = controller.getSelectedKeyPairIsProfile()
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    if profileMigrated:
      info "restart the app because of successfully migrated profile keypair"
      quit() # quit the app