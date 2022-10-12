type
  NotKeycardState* = ref object of State

proc newNotKeycardState*(flowType: FlowType, backState: State): NotKeycardState =
  result = NotKeycardState()
  result.setup(flowType, StateType.NotKeycard, backState)

proc delete*(self: NotKeycardState) =
  self.State.delete

method executeTertiaryCommand*(self: NotKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)