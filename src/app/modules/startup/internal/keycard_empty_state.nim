type
  KeycardEmptyState* = ref object of State

proc newKeycardEmptyState*(flowType: FlowType, backState: State): KeycardEmptyState =
  result = KeycardEmptyState()
  result.setup(flowType, StateType.KeycardEmpty, backState)

proc delete*(self: KeycardEmptyState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runLoadAccountFlow(true)

method resolveKeycardNextState*(self: KeycardEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, FlowType.FirstRunNewUserNewKeycardKeys, self)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, FlowType.FirstRunNewUserNewKeycardKeys, self)
