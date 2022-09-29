type
  KeycardRecognizedKeycardState* = ref object of State

proc newKeycardRecognizedKeycardState*(flowType: FlowType, backState: State): KeycardRecognizedKeycardState =
  result = KeycardRecognizedKeycardState()
  result.setup(flowType, StateType.KeycardRecognizedKeycard, backState)

proc delete*(self: KeycardRecognizedKeycardState) =
  self.State.delete

method executeBackCommand*(self: KeycardRecognizedKeycardState, controller: Controller) =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys or
    self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
      controller.cancelCurrentFlow()

method getNextPrimaryState*(self: KeycardRecognizedKeycardState, controller: Controller): State =
  if self.flowType == FlowType.FirstRunNewUserNewKeycardKeys:
    return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)
  if self.flowType == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    return createState(StateType.UserProfileEnterSeedPhrase, self.flowType, self.getBackState)
