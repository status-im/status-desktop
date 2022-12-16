type
  CreatingAccountNewSeedPhraseSuccessState* = ref object of State

proc newCreatingAccountNewSeedPhraseSuccessState*(flowType: FlowType, backState: State): CreatingAccountNewSeedPhraseSuccessState =
  result = CreatingAccountNewSeedPhraseSuccessState()
  result.setup(flowType, StateType.CreatingAccountNewSeedPhraseSuccess, backState)

proc delete*(self: CreatingAccountNewSeedPhraseSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: CreatingAccountNewSeedPhraseSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: CreatingAccountNewSeedPhraseSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)