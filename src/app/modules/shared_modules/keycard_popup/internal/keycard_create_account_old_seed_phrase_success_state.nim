type
  CreatingAccountOldSeedPhraseSuccessState* = ref object of State

proc newCreatingAccountOldSeedPhraseSuccessState*(flowType: FlowType, backState: State): CreatingAccountOldSeedPhraseSuccessState =
  result = CreatingAccountOldSeedPhraseSuccessState()
  result.setup(flowType, StateType.CreatingAccountOldSeedPhraseSuccess, backState)

proc delete*(self: CreatingAccountOldSeedPhraseSuccessState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: CreatingAccountOldSeedPhraseSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: CreatingAccountOldSeedPhraseSuccessState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)