type
  ChangingKeycardPairingCodeFailureState* = ref object of State

proc newChangingKeycardPairingCodeFailureState*(flowType: FlowType, backState: State): ChangingKeycardPairingCodeFailureState =
  result = ChangingKeycardPairingCodeFailureState()
  result.setup(flowType, StateType.ChangingKeycardPairingCodeFailure, backState)

proc delete*(self: ChangingKeycardPairingCodeFailureState) =
  self.State.delete

method executePrimaryCommand*(self: ChangingKeycardPairingCodeFailureState, controller: Controller) =
  if self.flowType == FlowType.ChangePairingCode:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeTertiaryCommand*(self: ChangingKeycardPairingCodeFailureState, controller: Controller) =
  if self.flowType == FlowType.ChangePairingCode:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)