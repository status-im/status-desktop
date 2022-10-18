type
  ChangingKeycardPairingCodeSuccessState* = ref object of State

proc newChangingKeycardPairingCodeSuccessState*(flowType: FlowType, backState: State): ChangingKeycardPairingCodeSuccessState =
  result = ChangingKeycardPairingCodeSuccessState()
  result.setup(flowType, StateType.ChangingKeycardPairingCodeSuccess, backState)

proc delete*(self: ChangingKeycardPairingCodeSuccessState) =
  self.State.delete

method executePrimaryCommand*(self: ChangingKeycardPairingCodeSuccessState, controller: Controller) =
  if self.flowType == FlowType.ChangePairingCode:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeTertiaryCommand*(self: ChangingKeycardPairingCodeSuccessState, controller: Controller) =
  if self.flowType == FlowType.ChangePairingCode:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)