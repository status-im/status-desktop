type
  SeedPhraseDisplayState* = ref object of State

proc newSeedPhraseDisplayState*(flowType: FlowType, backState: State): SeedPhraseDisplayState =
  result = SeedPhraseDisplayState()
  result.setup(flowType, StateType.SeedPhraseDisplay, backState)

proc delete*(self: SeedPhraseDisplayState) =
  self.State.delete

method executeTertiaryCommand*(self: SeedPhraseDisplayState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextPrimaryState*(self: SeedPhraseDisplayState, controller: Controller): State =
  return createState(StateType.SeedPhraseEnterWords, self.flowType, self)