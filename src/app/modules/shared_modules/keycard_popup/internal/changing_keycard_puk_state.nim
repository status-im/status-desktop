type
  ChangingKeycardPukState* = ref object of State

proc newChangingKeycardPukState*(flowType: FlowType, backState: State): ChangingKeycardPukState =
  result = ChangingKeycardPukState()
  result.setup(flowType, StateType.ChangingKeycardPuk, backState)

proc delete*(self: ChangingKeycardPukState) =
  self.State.delete

method executePreSecondaryStateCommand*(self: ChangingKeycardPukState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPuk:
    controller.storePukToKeycard(controller.getPuk())

method resolveKeycardNextState*(self: ChangingKeycardPukState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)