type
  CreatePukState* = ref object of State

proc newCreatePukState*(flowType: FlowType, backState: State): CreatePukState =
  result = CreatePukState()
  result.setup(flowType, StateType.CreatePuk, backState)

proc delete*(self: CreatePukState) =
  self.State.delete
  
method executeTertiaryCommand*(self: CreatePukState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextSecondaryState*(self: CreatePukState, controller: Controller): State =
  if self.flowType == FlowType.ChangeKeycardPuk:
    if controller.getPuk().len == PUKLengthForStatusApp:
      return createState(StateType.RepeatPuk, self.flowType, self)