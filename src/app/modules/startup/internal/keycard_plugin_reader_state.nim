type
  KeycardPluginReaderState* = ref object of State

proc newKeycardPluginReaderState*(flowType: FlowType, backState: State): KeycardPluginReaderState =
  result = KeycardPluginReaderState()
  result.setup(flowType, StateType.KeycardPluginReader, backState)

proc delete*(self: KeycardPluginReaderState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardPluginReaderState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    controller.runLoadAccountFlow()
  elif self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    controller.runLoadAccountFlow()
  elif self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runRecoverAccountFlow()  

method resolveKeycardNextState*(self: KeycardPluginReaderState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.resumeCurrentFlowLater()
      return nil
  if keycardFlowType == ResponseTypeValueInsertCard:
    return createState(StateType.KeycardInsertKeycard, self.flowType, self.getBackState)