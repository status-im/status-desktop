type
  FactoryResetSuccessState* = ref object of State

proc newFactoryResetSuccessState*(flowType: FlowType, backState: State): FactoryResetSuccessState =
  result = FactoryResetSuccessState()
  result.setup(flowType, StateType.FactoryResetSuccess, backState)

proc delete*(self: FactoryResetSuccessState) =
  self.State.delete

method executePrimaryCommand*(self: FactoryResetSuccessState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
  elif self.flowType == FlowType.SetupNewKeycard:
    controller.runLoadAccountFlow()

method executeTertiaryCommand*(self: FactoryResetSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method resolveKeycardNextState*(self: FactoryResetSuccessState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)