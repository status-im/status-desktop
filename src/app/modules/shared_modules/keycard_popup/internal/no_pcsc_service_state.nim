type NoPCSCServiceState* = ref object of State

proc newNoPCSCServiceState*(flowType: FlowType, backState: State): NoPCSCServiceState =
  result = NoPCSCServiceState()
  result.setup(flowType, StateType.NoPCSCService, backState)

proc delete*(self: NoPCSCServiceState) =
  self.State.delete

method executeCancelCommand*(self: NoPCSCServiceState, controller: Controller) =
  controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method executePrePrimaryStateCommand*(
    self: NoPCSCServiceState, controller: Controller
) =
  controller.reRunCurrentFlow()

method resolveKeycardNextState*(
    self: NoPCSCServiceState,
    keycardFlowType: string,
    keycardEvent: KeycardEvent,
    controller: Controller,
): State =
  return ensureReaderAndCardPresenceAndResolveNextState(
    self, keycardFlowType, keycardEvent, controller
  )
