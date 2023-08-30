type
  KeyPairMigrateSuccessState* = ref object of State

proc newKeyPairMigrateSuccessState*(flowType: FlowType, backState: State): KeyPairMigrateSuccessState =
  result = KeyPairMigrateSuccessState()
  result.setup(flowType, StateType.KeyPairMigrateSuccess, backState)

proc delete*(self: KeyPairMigrateSuccessState) =
  self.State.delete

method executeCancelCommand*(self: KeyPairMigrateSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    let profileMigrated = controller.getSelectedKeyPairIsProfile()
    if profileMigrated:
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    if controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid():
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePrePrimaryStateCommand*(self: KeyPairMigrateSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    let profileMigrated = controller.getSelectedKeyPairIsProfile()
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    if profileMigrated:
      info "restart the app because of successfully migrated profile keypair"
      quit() # quit the app
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let profileMigrated = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    if profileMigrated:
      info "restart the app because of successfully migrated profile keypair"
      quit() # quit the app

method executePreSecondaryStateCommand*(self: KeyPairMigrateSuccessState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let profileMigrated = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
    if profileMigrated:
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, FlowType.FactoryReset)