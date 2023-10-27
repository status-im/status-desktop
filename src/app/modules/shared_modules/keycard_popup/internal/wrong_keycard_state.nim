type
  WrongKeycardState* = ref object of State

proc newWrongKeycardState*(flowType: FlowType, backState: State): WrongKeycardState =
  result = WrongKeycardState()
  result.setup(flowType, StateType.WrongKeycard, backState)

proc delete*(self: WrongKeycardState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.FactoryReset:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
      return
  if self.flowType == FlowType.UnlockKeycard:
    if controller.getReturnToFlow() == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true, nextFlow = FlowType.MigrateFromAppToKeycard,
        forceFlow = controller.getForceFlow(), nextKeyUid = controller.getKeyPairForProcessing().getKeyUid())
      return
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.runLoginFlow()
    return

method executeCancelCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)