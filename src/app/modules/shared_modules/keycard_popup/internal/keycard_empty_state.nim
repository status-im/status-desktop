type
  KeycardEmptyState* = ref object of State

proc newKeycardEmptyState*(flowType: FlowType, backState: State): KeycardEmptyState =
  result = KeycardEmptyState()
  result.setup(flowType, StateType.KeycardEmpty, backState)

proc delete*(self: KeycardEmptyState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
      return
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getReturnToFlow() == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.MigrateFromAppToKeycard,
        forceFlow = controller.getForceFlow(), nextKeyUid = controller.getKeyPairForProcessing().getKeyUid())
      return
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
    return
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.runLoginFlow()
    return

method executeCancelCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
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

method resolveKeycardNextState*(self: KeycardEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)