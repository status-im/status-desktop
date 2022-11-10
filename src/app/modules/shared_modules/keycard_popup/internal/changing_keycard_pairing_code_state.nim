type
  ChangingKeycardPairingCodeState* = ref object of State

proc newChangingKeycardPairingCodeState*(flowType: FlowType, backState: State): ChangingKeycardPairingCodeState =
  result = ChangingKeycardPairingCodeState()
  result.setup(flowType, StateType.ChangingKeycardPairingCode, backState)

proc delete*(self: ChangingKeycardPairingCodeState) =
  self.State.delete

method executePreSecondaryStateCommand*(self: ChangingKeycardPairingCodeState, controller: Controller) =
  if self.flowType == FlowType.ChangePairingCode:
    controller.storePairingCodeToKeycard(controller.getPairingCode())

method resolveKeycardNextState*(self: ChangingKeycardPairingCodeState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)