type
  RepeatPukState* = ref object of State

proc newRepeatPukState*(flowType: FlowType, backState: State): RepeatPukState =
  result = RepeatPukState()
  result.setup(flowType, StateType.RepeatPuk, backState)

proc delete*(self: RepeatPukState) =
  self.State.delete

method executePreBackStateCommand*(self: RepeatPukState, controller: Controller) =
  controller.setPuk("")
  controller.setPukMatch(false)

method getNextSecondaryState*(self: RepeatPukState, controller: Controller): State =
  if not controller.getPukMatch():
    return
  if self.flowType == FlowType.ChangeKeycardPuk:
    return createState(StateType.ChangingKeycardPuk, self.flowType, nil)

method executePreTertiaryStateCommand*(self: RepeatPukState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)