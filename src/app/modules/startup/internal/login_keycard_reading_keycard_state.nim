import ../../../global/global_singleton

type
  LoginKeycardReadingKeycardState* = ref object of State

proc newLoginKeycardReadingKeycardState*(flowType: FlowType, backState: State): LoginKeycardReadingKeycardState =
  result = LoginKeycardReadingKeycardState()
  result.setup(flowType, StateType.LoginKeycardReadingKeycard, backState)

proc delete*(self: LoginKeycardReadingKeycardState) =
  self.State.delete

method getNextPrimaryState*(self: LoginKeycardReadingKeycardState, controller: Controller): State =
  let (flowType, flowEvent) = controller.getLastReceivedKeycardData()
  # this is used in case a keycard is not inserted in the moment when flow is run (we're animating an insertion)
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, flowType, flowEvent, controller)

method resolveKeycardNextState*(self: LoginKeycardReadingKeycardState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  # this is used in case a keycard is inserted and we jump to the first meaningful screen
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)