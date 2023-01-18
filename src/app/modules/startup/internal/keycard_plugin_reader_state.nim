type
  KeycardPluginReaderState* = ref object of State

proc newKeycardPluginReaderState*(flowType: FlowType, backState: State): KeycardPluginReaderState =
  result = KeycardPluginReaderState()
  result.setup(flowType, StateType.KeycardPluginReader, backState)

proc delete*(self: KeycardPluginReaderState) =
  self.State.delete

method executeBackCommand*(self: KeycardPluginReaderState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard or
    self.flowType == FlowType.FirstRunOldUserKeycardImport or
    self.flowType == FlowType.LostKeycardReplacement:
      controller.cancelCurrentFlow()

method resolveKeycardNextState*(self: KeycardPluginReaderState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)