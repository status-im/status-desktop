type
  EnterKeycardNameState* = ref object of State
    success: bool

proc newEnterKeycardNameState*(flowType: FlowType, backState: State): EnterKeycardNameState =
  result = EnterKeycardNameState()
  result.setup(flowType, StateType.EnterKeycardName, backState)
  result.success = false

proc delete*(self: EnterKeycardNameState) =
  self.State.delete

method getNextPrimaryState*(self: EnterKeycardNameState, controller: Controller): State =
  if self.flowType == FlowType.RenameKeycard:
    return createState(StateType.RenamingKeycard, self.flowType, nil)

method executeCancelCommand*(self: EnterKeycardNameState, controller: Controller) =
  if self.flowType == FlowType.RenameKeycard:
    controller.setPassword("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
