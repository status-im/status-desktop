type
  CreatingAccountOldSeedPhraseFailureState* = ref object of State

proc newCreatingAccountOldSeedPhraseFailureState*(flowType: FlowType, backState: State): CreatingAccountOldSeedPhraseFailureState =
  result = CreatingAccountOldSeedPhraseFailureState()
  result.setup(flowType, StateType.CreatingAccountOldSeedPhraseFailure, backState)

proc delete*(self: CreatingAccountOldSeedPhraseFailureState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: CreatingAccountOldSeedPhraseFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: CreatingAccountOldSeedPhraseFailureState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)