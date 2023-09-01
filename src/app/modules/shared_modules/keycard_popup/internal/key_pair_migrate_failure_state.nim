type
  KeyPairMigrateFailureState* = ref object of State

proc newKeyPairMigrateFailureState*(flowType: FlowType, backState: State): KeyPairMigrateFailureState =
  result = KeyPairMigrateFailureState()
  result.setup(flowType, StateType.KeyPairMigrateFailure, backState)

proc delete*(self: KeyPairMigrateFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeyPairMigrateFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.MigrateFromKeycardToApp:
      let profileMigrated = controller.getSelectedKeyPairIsProfile()
      if not profileMigrated:
        controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
        return
      info "quit the app because of profile migration failure"
      quit() # quit the app

method executeCancelCommand*(self: KeyPairMigrateFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.MigrateFromKeycardToApp:
      let profileMigrated = controller.getSelectedKeyPairIsProfile()
      if not profileMigrated:
        controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
        return
      info "quit the app because of profile migration failure"
      quit() # quit the app