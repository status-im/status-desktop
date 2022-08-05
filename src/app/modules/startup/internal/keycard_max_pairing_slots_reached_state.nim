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
    controller.resumeCurrentFlow()

method resolveKeycardNextState*(self: KeycardMaxPairingSlotsReachedState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard, self.getBackState)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard, self.getBackState)