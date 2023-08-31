type
  WrongKeycardState* = ref object of State

proc newWrongKeycardState*(flowType: FlowType, backState: State): WrongKeycardState =
  result = WrongKeycardState()
  result.setup(flowType, StateType.WrongKeycard, backState)

proc delete*(self: WrongKeycardState) =
  self.State.delete

method executePrePrimaryStateCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.FactoryReset:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)

method executeCancelCommand*(self: WrongKeycardState, controller: Controller) =
  if self.flowType == FlowType.Authentication or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.FactoryReset:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)