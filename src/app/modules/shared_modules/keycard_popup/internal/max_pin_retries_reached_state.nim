type
  MaxPinRetriesReachedState* = ref object of State

proc newMaxPinRetriesReachedState*(flowType: FlowType, backState: State): MaxPinRetriesReachedState =
  result = MaxPinRetriesReachedState()
  result.setup(flowType, StateType.MaxPinRetriesReached, backState)

proc delete*(self: MaxPinRetriesReachedState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: MaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.UnlockKeycard, forceFlow = controller.getForceFlow(),
      nextKeyUid = controller.getKeyPairForProcessing().getKeyUid(), returnToFlow = FlowType.MigrateFromAppToKeycard)

method getNextPrimaryState*(self: MaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.runSharedModuleFlow(FlowType.UnlockKeycard, controller.getKeyPairForProcessing().getKeyUid())
  if self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.DisplayKeycardContent:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      controller.runSharedModuleFlow(FlowType.UnlockKeycard)
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      let currValue = extractPredefinedKeycardDataToNumber(controller.getKeycardData())
      if (currValue and PredefinedKeycardData.DisableSeedPhraseForUnlock.int) > 0:
        controller.runSharedModuleFlow(FlowType.UnlockKeycard)
        return
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = true))
      controller.runSharedModuleFlow(FlowType.UnlockKeycard)

method executeCancelCommand*(self: MaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.DisableSeedPhraseForUnlock, add = false))
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)