type
  CopyToKeycardState* = ref object of State

proc newCopyToKeycardState*(flowType: FlowType, backState: State): CopyToKeycardState =
  result = CopyToKeycardState()
  result.setup(flowType, StateType.CopyToKeycard, backState)

proc delete*(self: CopyToKeycardState) =
  self.State.delete

method getNextPrimaryState*(self: CopyToKeycardState, controller: Controller): State =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    return createState(StateType.EnterSeedPhrase, self.flowType, self)

method executeCancelCommand*(self: CopyToKeycardState, controller: Controller) =
  if self.flowType == FlowType.CreateCopyOfAKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)