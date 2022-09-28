type
  KeycardPluginReaderState* = ref object of State

proc newKeycardPluginReaderState*(flowType: FlowType, backState: State): KeycardPluginReaderState =
  result = KeycardPluginReaderState()
  result.setup(flowType, StateType.KeycardPluginReader, backState)

proc delete*(self: KeycardPluginReaderState) =
  self.State.delete

method executeBackCommand*(self: KeycardPluginReaderState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.cancelCurrentFlow()

method resolveKeycardNextState*(self: KeycardPluginReaderState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)