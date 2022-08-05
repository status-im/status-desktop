type
  InsertKeycardState* = ref object of State

proc newInsertKeycardState*(flowType: FlowType, backState: State): InsertKeycardState =
  result = InsertKeycardState()
  result.setup(flowType, StateType.InsertKeycard, backState)

proc delete*(self: InsertKeycardState) =
  self.State.delete

method executePrimaryCommand*(self: InsertKeycardState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: InsertKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if keycardFlowType == ResponseTypeValueCardInserted:
    return createState(StateType.ReadingKeycard, self.flowType, nil)
  return nil