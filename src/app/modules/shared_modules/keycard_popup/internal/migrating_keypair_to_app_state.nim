type
  MigratingKeypairToAppState* = ref object of State
    migrationOk: bool

proc newMigratingKeypairToAppState*(flowType: FlowType, backState: State): MigratingKeypairToAppState =
  result = MigratingKeypairToAppState()
  result.setup(flowType, StateType.MigratingKeypairToApp, backState)

proc delete*(self: MigratingKeypairToAppState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: MigratingKeypairToAppState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let sp = controller.getSeedPhrase()
    let password = controller.getPassword()
    let kpForProcessing = controller.getKeyPairForProcessing()
    controller.migrateNonProfileKeycardKeypairToApp(kpForProcessing.getKeyUid(), sp, password,
      doPasswordHashing = not singletonInstance.userProfile.getIsKeycardUser())

method executePreSecondaryStateCommand*(self: MigratingKeypairToAppState, controller: Controller) =
  ## Secondary action is called after each async action during migration process.
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    self.migrationOk = controller.getAddingMigratedKeypairSuccess()

method getNextSecondaryState*(self: MigratingKeypairToAppState, controller: Controller): State =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    if not self.migrationOk:
      return createState(StateType.KeyPairMigrateFailure, self.flowType, nil)
    return createState(StateType.KeyPairMigrateSuccess, self.flowType, nil)