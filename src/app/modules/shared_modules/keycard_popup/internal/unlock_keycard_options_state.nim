type
  UnlockKeycardOptionsState* = ref object of State

proc newUnlockKeycardOptionsState*(flowType: FlowType, backState: State): UnlockKeycardOptionsState =
  result = UnlockKeycardOptionsState()
  result.setup(flowType, StateType.UnlockKeycardOptions, backState)

proc delete*(self: UnlockKeycardOptionsState) =
  self.State.delete

method getNextPrimaryState*(self: UnlockKeycardOptionsState, controller: Controller): State =
  if self.flowType == FlowType.UnlockKeycard:
    return createState(StateType.EnterSeedPhrase, self.flowType, self)

method getNextSecondaryState*(self: UnlockKeycardOptionsState, controller: Controller): State =
  if self.flowType == FlowType.UnlockKeycard:
    return createState(StateType.EnterPuk, self.flowType, self)

method executePreTertiaryStateCommand*(self: UnlockKeycardOptionsState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)