type
  KeycardNotEmptyState* = ref object of State

proc newKeycardNotEmptyState*(flowType: FlowType, backState: State): KeycardNotEmptyState =
  result = KeycardNotEmptyState()
  result.setup(flowType, StateType.KeycardNotEmpty, backState)

proc delete*(self: KeycardNotEmptyState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: KeycardNotEmptyState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      controller.runGetMetadataFlow(resolveAddress = true)
      return
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    let hideKeypair = not isPredefinedKeycardDataFlagSet(controller.getKeycardData(), PredefinedKeycardData.CopyFromAKeycardPartDone)
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = hideKeypair))
    controller.runGetMetadataFlow(resolveAddress = true)

method executeCancelCommand*(self: KeycardNotEmptyState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: KeycardNotEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)