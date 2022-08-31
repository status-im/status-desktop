type
  MigratingKeyPairState* = ref object of State
    migrationSuccess: bool

proc newMigratingKeyPairState*(flowType: FlowType, backState: State): MigratingKeyPairState =
  result = MigratingKeyPairState()
  result.setup(flowType, StateType.MigratingKeyPair, backState)
  result.migrationSuccess = false

proc delete*(self: MigratingKeyPairState) =
  self.State.delete

method executePrimaryCommand*(self: MigratingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    # Ran authentication popup and get pass from there...
    let password = controller.getPassword()
    self.migrationSuccess = controller.verifyPassword(password)
    if controller.getSelectedKeyPairIsProfile():
      self.migrationSuccess = self.migrationSuccess and controller.convertToKeycardAccount(password)
    if not self.migrationSuccess:
      return
    controller.runStoreMetadataFlow(controller.getSelectedKeyPairName(), controller.getPin(), 
      controller.getSelectedKeyPairWalletPaths())

method getNextPrimaryState*(self: MigratingKeyPairState, controller: Controller): State =
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