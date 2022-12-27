type
  SeedPhraseAlreadyInUseState* = ref object of State
    verifiedSeedPhrase: bool

proc newSeedPhraseAlreadyInUseState*(flowType: FlowType, backState: State): SeedPhraseAlreadyInUseState =
  result = SeedPhraseAlreadyInUseState()
  result.setup(flowType, StateType.SeedPhraseAlreadyInUse, backState)

proc delete*(self: SeedPhraseAlreadyInUseState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: SeedPhraseAlreadyInUseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executePreSecondaryStateCommand*(self: SeedPhraseAlreadyInUseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard:
      controller.switchToWalletSection()
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: SeedPhraseAlreadyInUseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)