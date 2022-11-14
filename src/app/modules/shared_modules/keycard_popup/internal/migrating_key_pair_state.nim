type
  MigratingKeyPairState* = ref object of State
    authenticationDone: bool 
    authenticationOk: bool
    addingMigratedKeypairDone: bool
    addingMigratedKeypairOk: bool
    profileConversionDone: bool
    profileConversionOk: bool

proc newMigratingKeyPairState*(flowType: FlowType, backState: State): MigratingKeyPairState =
  result = MigratingKeyPairState()
  result.setup(flowType, StateType.MigratingKeyPair, backState)
  result.authenticationDone = false
  result.authenticationOk = false
  result.addingMigratedKeypairDone = false
  result.addingMigratedKeypairOk = false
  result.profileConversionDone = false
  result.profileConversionOk = false

proc delete*(self: MigratingKeyPairState) =
  self.State.delete

proc doMigration(self: MigratingKeyPairState, controller: Controller) =
  let selectedKeyPairDto = controller.getSelectedKeyPairDto()
  controller.addMigratedKeyPair(selectedKeyPairDto)

proc doConversion(self: MigratingKeyPairState, controller: Controller) =
  let password = controller.getPassword()
  controller.convertSelectedKeyPairToKeycardAccount(password)

proc runStoreMetadataFlow(self: MigratingKeyPairState, controller: Controller) =
  let selectedKeyPairDto = controller.getSelectedKeyPairDto()
  controller.runStoreMetadataFlow(selectedKeyPairDto.keycardName, controller.getPin(), controller.getSelectedKeyPairWalletPaths())

method executePrePrimaryStateCommand*(self: MigratingKeyPairState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if controller.getSelectedKeyPairIsProfile():
      controller.authenticateUser()
    else:
      self.doMigration(controller)

method executePreSecondaryStateCommand*(self: MigratingKeyPairState, controller: Controller) =
  ## Secondary action is called after each async action during migration process. 
  if self.flowType == FlowType.SetupNewKeycard:
    if controller.getSelectedKeyPairIsProfile():
      if not self.authenticationDone:
        self.authenticationDone = true
        let password = controller.getPassword()
        self.authenticationOk = controller.verifyPassword(password)
        if self.authenticationOk:
          self.doMigration(controller)
          return
      if not self.addingMigratedKeypairDone:
        self.addingMigratedKeypairDone = true
        self.addingMigratedKeypairOk = controller.getAddingMigratedKeypairSuccess()
        if self.addingMigratedKeypairOk:
          self.doConversion(controller)
          return
      if not self.profileConversionDone:
        self.profileConversionDone = true
        self.profileConversionOk = controller.getConvertingProfileSuccess()
        if self.profileConversionOk:
          self.runStoreMetadataFlow(controller)
    else:
      if not self.addingMigratedKeypairDone:
        self.addingMigratedKeypairDone = true
        self.addingMigratedKeypairOk = controller.getAddingMigratedKeypairSuccess()
        if self.addingMigratedKeypairOk:
          self.runStoreMetadataFlow(controller)

method getNextSecondaryState*(self: MigratingKeyPairState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if self.authenticationDone and not self.authenticationOk or
      self.addingMigratedKeypairDone and not self.addingMigratedKeypairOk or
      self.profileConversionDone and not self.profileConversionOk:
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