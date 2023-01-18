type
  KeycardInsertedKeycardState* = ref object of State

proc newKeycardInsertedKeycardState*(flowType: FlowType, backState: State): KeycardInsertedKeycardState =
  result = KeycardInsertedKeycardState()
  result.setup(flowType, StateType.KeycardInsertedKeycard, backState)

proc delete*(self: KeycardInsertedKeycardState) =
  self.State.delete

method executeBackCommand*(self: KeycardInsertedKeycardState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard or
    self.flowType == FlowType.FirstRunOldUserKeycardImport or
    self.flowType == FlowType.LostKeycardReplacement:
      controller.cancelCurrentFlow()

method getNextPrimaryState*(self: KeycardInsertedKeycardState, controller: Controller): State =
  return createState(StateType.KeycardReadingKeycard, self.flowType, self.getBackState)
