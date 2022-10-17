type
  WrongKeycardState* = ref object of State

proc newWrongKeycardState*(flowType: FlowType, backState: State): WrongKeycardState =
  result = WrongKeycardState()
  result.setup(flowType, StateType.WrongKeycard, backState)

proc delete*(self: WrongKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeTertiaryCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)