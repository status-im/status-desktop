type
  PluginReaderState* = ref object of State

proc newPluginReaderState*(flowType: FlowType, backState: State): PluginReaderState =
  result = PluginReaderState()
  result.setup(flowType, StateType.PluginReader, backState)

proc delete*(self: PluginReaderState) =
  self.State.delete

method executePreBackStateCommand*(self: PluginReaderState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method executeCancelCommand*(self: PluginReaderState, controller: Controller) =
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

method resolveKeycardNextState*(self: PluginReaderState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  return readingKeycard(self, keycardFlowType, keycardEvent, controller)