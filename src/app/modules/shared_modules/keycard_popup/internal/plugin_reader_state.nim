type
  PluginReaderState* = ref object of State

proc newPluginReaderState*(flowType: FlowType, backState: State): PluginReaderState =
  result = PluginReaderState()
  result.setup(flowType, StateType.PluginReader, backState)

proc delete*(self: PluginReaderState) =
  self.State.delete

method executePrimaryCommand*(self: PluginReaderState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: PluginReaderState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)