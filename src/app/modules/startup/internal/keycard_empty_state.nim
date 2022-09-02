type
  KeycardEmptyState* = ref object of State

proc newKeycardEmptyState*(flowType: FlowType, backState: State): KeycardEmptyState =
  result = KeycardEmptyState()
  result.setup(flowType, StateType.KeycardEmpty, backState)

proc delete*(self: KeycardEmptyState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    self.setFlowType(FlowType.FirstRunNewUserNewKeycardKeys)
    controller.runLoadAccountFlow()

method resolveKeycardNextState*(self: KeycardEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)