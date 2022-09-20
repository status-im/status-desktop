type
  KeycardNotEmptyState* = ref object of State

proc newKeycardNotEmptyState*(flowType: FlowType, backState: State): KeycardNotEmptyState =
  result = KeycardNotEmptyState()
  result.setup(flowType, StateType.KeycardNotEmpty, backState)

proc delete*(self: KeycardNotEmptyState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardNotEmptyState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
    controller.runGetMetadataFlow(resolveAddress = true)

method executeTertiaryCommand*(self: KeycardNotEmptyState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: KeycardNotEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)