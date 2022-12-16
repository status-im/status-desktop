type
  FactoryResetConfirmationDisplayMetadataState* = ref object of State

proc newFactoryResetConfirmationDisplayMetadataState*(flowType: FlowType, backState: State): FactoryResetConfirmationDisplayMetadataState =
  result = FactoryResetConfirmationDisplayMetadataState()
  result.setup(flowType, StateType.FactoryResetConfirmationDisplayMetadata, backState)

proc delete*(self: FactoryResetConfirmationDisplayMetadataState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: FactoryResetConfirmationDisplayMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.runGetAppInfoFlow(factoryReset = true)
  elif self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
      controller.runGetAppInfoFlow(factoryReset = true)
    
method executeCancelCommand*(self: FactoryResetConfirmationDisplayMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.CreateCopyOfAKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: FactoryResetConfirmationDisplayMetadataState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)