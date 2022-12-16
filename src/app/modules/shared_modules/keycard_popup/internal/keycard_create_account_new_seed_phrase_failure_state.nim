type
  CreatingAccountNewSeedPhraseFailureState* = ref object of State

proc newCreatingAccountNewSeedPhraseFailureState*(flowType: FlowType, backState: State): CreatingAccountNewSeedPhraseFailureState =
  result = CreatingAccountNewSeedPhraseFailureState()
  result.setup(flowType, StateType.CreatingAccountNewSeedPhraseFailure, backState)

proc delete*(self: CreatingAccountNewSeedPhraseFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: CreatingAccountNewSeedPhraseFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: CreatingAccountNewSeedPhraseFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)