type
  KeycardMaxPukRetriesReachedState* = ref object of State

proc newKeycardMaxPukRetriesReachedState*(flowType: FlowType, backState: State): KeycardMaxPukRetriesReachedState =
  result = KeycardMaxPukRetriesReachedState()
  result.setup(flowType, StateType.KeycardMaxPukRetriesReached, backState)

proc delete*(self: KeycardMaxPukRetriesReachedState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardMaxPukRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runFactoryResetPopup()

method executeSecondaryCommand*(self: KeycardMaxPukRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runRecoverAccountFlow()

method resolveKeycardNextState*(self: KeycardMaxPukRetriesReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)