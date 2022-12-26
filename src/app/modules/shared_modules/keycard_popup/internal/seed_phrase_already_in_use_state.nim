type
  SeedPhraseAlreadyInUseState* = ref object of State
    verifiedSeedPhrase: bool

proc newSeedPhraseAlreadyInUseState*(flowType: FlowType, backState: State): SeedPhraseAlreadyInUseState =
  result = SeedPhraseAlreadyInUseState()
  result.setup(flowType, StateType.SeedPhraseAlreadyInUse, backState)

proc delete*(self: SeedPhraseAlreadyInUseState) =
  self.State.delete

method executeCancelCommand*(self: SeedPhraseAlreadyInUseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)