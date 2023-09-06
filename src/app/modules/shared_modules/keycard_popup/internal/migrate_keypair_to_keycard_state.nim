type
  MigrateKeypairToKeycardState* = ref object of State

proc newMigrateKeypairToKeycardState*(flowType: FlowType, backState: State): MigrateKeypairToKeycardState =
  result = MigrateKeypairToKeycardState()
  result.setup(flowType, StateType.MigrateKeypairToKeycard, backState)

proc delete*(self: MigrateKeypairToKeycardState) =
  self.State.delete

method executeCancelCommand*(self: MigrateKeypairToKeycardState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePrePrimaryStateCommand*(self: MigrateKeypairToKeycardState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromAppToKeycard:
    controller.runLoginFlow()

method resolveKeycardNextState*(self: MigrateKeypairToKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent,
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)