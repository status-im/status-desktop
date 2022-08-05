type
  PluginReaderState* = ref object of State

proc newPluginReaderState*(flowType: FlowType, backState: State): PluginReaderState =
  result = PluginReaderState()
  result.setup(flowType, StateType.PluginReader, backState)

proc delete*(self: PluginReaderState) =
  self.State.delete

method executePrimaryCommand*(self: PluginReaderState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: PluginReaderState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.resumeCurrentFlowLater()
      return nil
  if keycardFlowType == ResponseTypeValueInsertCard:
    return createState(StateType.InsertKeycard, self.flowType, nil)