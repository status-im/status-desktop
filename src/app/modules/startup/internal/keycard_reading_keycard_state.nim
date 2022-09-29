type
  KeycardReadingKeycardState* = ref object of State

proc newKeycardReadingKeycardState*(flowType: FlowType, backState: State): KeycardReadingKeycardState =
  result = KeycardReadingKeycardState()
  result.setup(flowType, StateType.KeycardReadingKeycard, backState)

proc delete*(self: KeycardReadingKeycardState) =
  self.State.delete

method executeBackCommand*(self: KeycardReadingKeycardState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      controller.cancelCurrentFlow()

method getNextPrimaryState*(self: KeycardReadingKeycardState, controller: Controller): State =
  let (flowType, flowEvent) = controller.getLastReceivedKeycardData()
  # this is used in case a keycard is not inserted in the moment when flow is run (we're animating an insertion)
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, flowType, flowEvent, controller)

method resolveKeycardNextState*(self: KeycardReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  # this is used in case a keycard is inserted and we jump to the first meaningful screen
  return ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)