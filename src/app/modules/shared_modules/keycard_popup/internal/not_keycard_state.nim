type
  NotKeycardState* = ref object of State

proc newNotKeycardState*(flowType: FlowType, backState: State): NotKeycardState =
  result = NotKeycardState()
  result.setup(flowType, StateType.NotKeycard, backState)

proc delete*(self: NotKeycardState) =
  self.State.delete

method executeCancelCommand*(self: NotKeycardState, controller: Controller) =
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

method executePrePrimaryStateCommand*(self: NotKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    if isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone):
      controller.runLoadAccountFlow(seedPhraseLength = 0, seedPhrase = "", pin = controller.getPin())
    return
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.runLoginFlow()
    return

method resolveKeycardNextState*(self: NotKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)