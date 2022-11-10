type
  ChangingKeycardPinState* = ref object of State

proc newChangingKeycardPinState*(flowType: FlowType, backState: State): ChangingKeycardPinState =
  result = ChangingKeycardPinState()
  result.setup(flowType, StateType.ChangingKeycardPin, backState)

proc delete*(self: ChangingKeycardPinState) =
  self.State.delete

method executePreSecondaryStateCommand*(self: ChangingKeycardPinState, controller: Controller) =
  if self.flowType == FlowType.ChangeKeycardPin:
    controller.storePinToKeycard(controller.getPin(), "")

method resolveKeycardNextState*(self: ChangingKeycardPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)