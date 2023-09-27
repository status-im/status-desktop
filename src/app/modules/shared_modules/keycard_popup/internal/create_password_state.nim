type
  CreatePasswordState* = ref object of State

proc newCreatePasswordState*(flowType: FlowType, backState: State): CreatePasswordState =
  result = CreatePasswordState()
  result.setup(flowType, StateType.CreatePassword, backState)

proc delete*(self: CreatePasswordState) =
  self.State.delete

method executeCancelCommand*(self: CreatePasswordState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executePreBackStateCommand*(self: CreatePasswordState, controller: Controller) =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    controller.setPassword("")

method getNextPrimaryState*(self: CreatePasswordState, controller: Controller): State =
  if self.flowType == FlowType.MigrateFromKeycardToApp:
    return createState(StateType.ConfirmPassword, self.flowType, self)