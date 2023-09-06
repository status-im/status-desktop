type
  BiometricsState* = ref object of State
    storeToKeychain: bool

proc newBiometricsState*(flowType: FlowType, backState: State): BiometricsState =
  result = BiometricsState()
  result.setup(flowType, StateType.Biometrics, backState)

proc delete*(self: BiometricsState) =
  self.State.delete

method executeCancelCommand*(self: BiometricsState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

proc doAuthentication(self: BiometricsState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let migratingProfile = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
    if not migratingProfile:
      return
    controller.authenticateUser()
    return
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.authenticateUser()
    return

method executePrePrimaryStateCommand*(self: BiometricsState, controller: Controller) =
  self.storeToKeychain = true
  self.doAuthentication(controller)

method executePreSecondaryStateCommand*(self: BiometricsState, controller: Controller) =
  self.storeToKeychain = false
  self.doAuthentication(controller)

method executePreTertiaryStateCommand*(self: BiometricsState, controller: Controller) =
  if self.storeToKeychain:
    singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_STORE)
    return
  singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NEVER)

method getNextTertiaryState*(self: BiometricsState, controller: Controller): State =
  ## Tertiary action is called after each async action during migration process.
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    let migratingProfile = controller.getKeyPairForProcessing().getKeyUid() == singletonInstance.userProfile.getKeyUid()
    if not migratingProfile:
      return
    return createState(StateType.MigratingKeypairToApp, self.flowType, nil)
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    return createState(StateType.MigratingKeypairToKeycard, self.flowType, nil)