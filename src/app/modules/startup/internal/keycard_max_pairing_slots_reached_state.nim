type
  KeycardMaxPairingSlotsReachedState* = ref object of State

proc newKeycardMaxPairingSlotsReachedState*(flowType: FlowType, backState: State): KeycardMaxPairingSlotsReachedState =
  result = KeycardMaxPairingSlotsReachedState()
  result.setup(flowType, StateType.KeycardMaxPairingSlotsReached, backState)

proc delete*(self: KeycardMaxPairingSlotsReachedState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardMaxPairingSlotsReachedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runFactoryResetPopup()

method executeSecondaryCommand*(self: KeycardMaxPairingSlotsReachedState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    controller.runRecoverAccountFlow()

method resolveKeycardNextState*(self: KeycardMaxPairingSlotsReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)