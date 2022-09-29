type
  KeycardInsertKeycardState* = ref object of State

proc newKeycardInsertKeycardState*(flowType: FlowType, backState: State): KeycardInsertKeycardState =
  result = KeycardInsertKeycardState()
  result.setup(flowType, StateType.KeycardInsertKeycard, backState)

proc delete*(self: KeycardInsertKeycardState) =
  self.State.delete

method executeBackCommand*(self: KeycardInsertKeycardState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard or
    self.flowType == FlowType.FirstRunOldUserKeycardImport:
      controller.cancelCurrentFlow()

method resolveKeycardNextState*(self: KeycardInsertKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextOnboardingState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if keycardFlowType == ResponseTypeValueInsertCard and 
    keycardEvent.error.len > 0 and
    keycardEvent.error == ErrorConnection:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = true))
      return nil
  if keycardFlowType == ResponseTypeValueCardInserted:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.WronglyInsertedCard, add = false))
    return createState(StateType.KeycardInsertedKeycard, self.flowType, self.getBackState)
  return nil