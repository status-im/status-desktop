type
  KeycardMaxPukRetriesReachedState* = ref object of State

proc newKeycardMaxPukRetriesReachedState*(flowType: FlowType, backState: State): KeycardMaxPukRetriesReachedState =
  result = KeycardMaxPukRetriesReachedState()
  result.setup(flowType, StateType.KeycardMaxPukRetriesReached, backState)

proc delete*(self: KeycardMaxPukRetriesReachedState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardMaxPukRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runLoadAccountFlow(true)
  elif self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlow(true)

method executeSecondaryCommand*(self: KeycardMaxPukRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.resumeCurrentFlow()
  elif self.flowType == FlowType.AppLogin:
    controller.resumeCurrentFlow()

method resolveKeycardNextState*(self: KeycardMaxPukRetriesReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard, self.getBackState)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, self.flowType, self.getBackState)