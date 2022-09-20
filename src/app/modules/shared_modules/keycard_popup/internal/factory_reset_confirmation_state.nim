type
  FactoryResetConfirmationState* = ref object of State

proc newFactoryResetConfirmationState*(flowType: FlowType, backState: State): FactoryResetConfirmationState =
  result = FactoryResetConfirmationState()
  result.setup(flowType, StateType.FactoryResetConfirmation, backState)

proc delete*(self: FactoryResetConfirmationState) =
  self.State.delete

method executePrimaryCommand*(self: FactoryResetConfirmationState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.runGetAppInfoFlow(factoryReset = true)
  elif self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.HideKeyPair, add = true))
    controller.runGetAppInfoFlow(factoryReset = true)
    
method executeTertiaryCommand*(self: FactoryResetConfirmationState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: FactoryResetConfirmationState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)