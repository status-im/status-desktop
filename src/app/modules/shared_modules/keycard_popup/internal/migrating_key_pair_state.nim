type
  MigratingKeyPairState* = ref object of State
    migrationSuccess: bool

proc newMigratingKeyPairState*(flowType: FlowType, backState: State): MigratingKeyPairState =
  result = MigratingKeyPairState()
  result.setup(flowType, StateType.MigratingKeyPair, backState)
  result.migrationSuccess = false

proc delete*(self: MigratingKeyPairState) =
  self.State.delete

proc doMigration(self: MigratingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    let password = controller.getPassword()
    controller.setPassword("")
    if controller.getSelectedKeyPairIsProfile():
      self.migrationSuccess = controller.verifyPassword(password)
      if not self.migrationSuccess:
        return
    let selectedKeyPairDto = controller.getSelectedKeyPairDto()
    self.migrationSuccess = controller.addMigratedKeyPair(selectedKeyPairDto)
    if not self.migrationSuccess:
      return
    if controller.getSelectedKeyPairIsProfile():
      self.migrationSuccess = self.migrationSuccess and controller.convertSelectedKeyPairToKeycardAccount(password)
    if not self.migrationSuccess:
      return
    controller.runStoreMetadataFlow(selectedKeyPairDto.keycardName, controller.getPin(), 
      controller.getSelectedKeyPairWalletPaths())

method executePrimaryCommand*(self: MigratingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if controller.getSelectedKeyPairIsProfile():
      controller.authenticateUser()
    else:
      self.doMigration(controller)

method executeSecondaryCommand*(self: MigratingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    self.doMigration(controller)

method getNextSecondaryState*(self: MigratingKeyPairState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.migrationSuccess:
      return createState(StateType.KeyPairMigrateFailure, self.flowType, nil)

method resolveKeycardNextState*(self: MigratingKeyPairState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        return createState(StateType.KeyPairMigrateSuccess, self.flowType, nil)