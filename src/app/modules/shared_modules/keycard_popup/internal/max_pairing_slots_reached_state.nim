type
  MaxPairingSlotsReachedState* = ref object of State

proc newMaxPairingSlotsReachedState*(flowType: FlowType, backState: State): MaxPairingSlotsReachedState =
  result = MaxPairingSlotsReachedState()
  result.setup(flowType, StateType.MaxPairingSlotsReached, backState)

proc delete*(self: MaxPairingSlotsReachedState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: MaxPairingSlotsReachedState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.UnlockKeycard, forceFlow = controller.getForceFlow(),
      nextKeyUid = controller.getKeyPairForProcessing().getKeyUid(), returnToFlow = FlowType.MigrateFromAppToKeycard)

method getNextPrimaryState*(self: MaxPairingSlotsReachedState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.runSharedModuleFlow(FlowType.UnlockKeycard, controller.getKeyPairForProcessing().getKeyUid())
  if self.flowType == FlowType.UnlockKeycard:
    return createState(StateType.EnterSeedPhrase, self.flowType, self)

method executeCancelCommand*(self: MaxPairingSlotsReachedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)