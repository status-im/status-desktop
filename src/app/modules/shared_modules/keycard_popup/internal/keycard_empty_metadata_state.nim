type
  KeycardEmptyMetadataState* = ref object of State

proc newKeycardEmptyMetadataState*(flowType: FlowType, backState: State): KeycardEmptyMetadataState =
  result = KeycardEmptyMetadataState()
  result.setup(flowType, StateType.KeycardEmptyMetadata, backState)

proc delete*(self: KeycardEmptyMetadataState) =
  self.State.delete

method executeCancelCommand*(self: KeycardEmptyMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executePrePrimaryStateCommand*(self: KeycardEmptyMetadataState, controller: Controller) =
  if self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.RenameKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
      return
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getReturnToFlow() == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.MigrateFromAppToKeycard,
        forceFlow = controller.getForceFlow(), nextKeyUid = controller.getKeyPairForProcessing().getKeyUid())
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    return
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if not isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    return
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.runLoginFlow()
    return

method getNextPrimaryState*(self: KeycardEmptyMetadataState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)

method resolveKeycardNextState*(self: KeycardEmptyMetadataState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)