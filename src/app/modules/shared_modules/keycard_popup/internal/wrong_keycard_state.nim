type
  WrongKeycardState* = ref object of State

proc newWrongKeycardState*(flowType: FlowType, backState: State): WrongKeycardState =
  result = WrongKeycardState()
  result.setup(flowType, StateType.WrongKeycard, backState)

proc delete*(self: WrongKeycardState) =
  self.State.delete

method executeTertiaryCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)