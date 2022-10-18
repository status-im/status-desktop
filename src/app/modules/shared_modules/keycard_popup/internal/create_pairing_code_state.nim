type
  CreatePairingCodeState* = ref object of State

proc newCreatePairingCodeState*(flowType: FlowType, backState: State): CreatePairingCodeState =
  result = CreatePairingCodeState()
  result.setup(flowType, StateType.CreatePairingCode, backState)

proc delete*(self: CreatePairingCodeState) =
  self.State.delete

method getNextPrimaryState*(self: CreatePairingCodeState, controller: Controller): State =
  if self.flowType == FlowType.ChangePairingCode:
    if controller.getPairingCode().len >= 0:
      return createState(StateType.ChangingKeycardPairingCode, self.flowType, nil)
    return createState(StateType.ChangingKeycardPairingCodeFailure, self.flowType, nil)

method executeTertiaryCommand*(self: CreatePairingCodeState, controller: Controller) =
  if self.flowType == FlowType.ChangePairingCode:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)