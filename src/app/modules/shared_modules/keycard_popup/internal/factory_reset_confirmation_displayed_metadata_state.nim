type
  FactoryResetConfirmationDisplayMetadataState* = ref object of State

proc newFactoryResetConfirmationDisplayMetadataState*(flowType: FlowType, backState: State): FactoryResetConfirmationDisplayMetadataState =
  result = FactoryResetConfirmationDisplayMetadataState()
  result.setup(flowType, StateType.FactoryResetConfirmationDisplayMetadata, backState)

proc delete*(self: FactoryResetConfirmationDisplayMetadataState) =
  self.State.delete

method executePrimaryCommand*(self: FactoryResetConfirmationDisplayMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.runGetAppInfoFlow(factoryReset = true)
  elif self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(getPredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
    controller.runGetAppInfoFlow(factoryReset = true)
    
method executeSecondaryCommand*(self: FactoryResetConfirmationDisplayMetadataState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: FactoryResetConfirmationDisplayMetadataState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)