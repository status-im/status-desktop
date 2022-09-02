type
  CreatePinState* = ref object of State

proc newCreatePinState*(flowType: FlowType, backState: State): CreatePinState =
  result = CreatePinState()
  result.setup(flowType, StateType.CreatePin, backState)

proc delete*(self: CreatePinState) =
  self.State.delete
  
method executeBackCommand*(self: CreatePinState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method executeSecondaryCommand*(self: CreatePinState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextTertiaryState*(self: CreatePinState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if controller.getPin().len == PINLengthForStatusApp:
      return createState(StateType.RepeatPin, self.flowType, self)
  return nil