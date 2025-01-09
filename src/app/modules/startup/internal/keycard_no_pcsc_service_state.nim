type KeycardNoPCSCServiceState* = ref object of State

proc newKeycardNoPCSCServiceState*(
    flowType: FlowType, backState: State
): KeycardNoPCSCServiceState =
  result = KeycardNoPCSCServiceState()
  result.setup(flowType, StateType.KeycardNoPCSCService, backState)

proc delete*(self: KeycardNoPCSCServiceState) =
  self.State.delete

method executeBackCommand*(self: KeycardNoPCSCServiceState, controller: Controller) =
  controller.cancelCurrentFlow()

method executePrimaryCommand*(self: KeycardNoPCSCServiceState, controller: Controller) =
  controller.reRunCurrentFlow()

method getNextPrimaryState*(
    self: KeycardNoPCSCServiceState, controller: Controller
): State =
  return self.getBackState
