type
  CreatePinState* = ref object of State

proc newCreatePinState*(flowType: FlowType, backState: State): CreatePinState =
  result = CreatePinState()
  result.setup(flowType, StateType.CreatePin, backState)

proc delete*(self: CreatePinState) =
  self.State.delete
  
method executePreBackStateCommand*(self: CreatePinState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method executePreTertiaryStateCommand*(self: CreatePinState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method getNextSecondaryState*(self: CreatePinState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.ChangeKeycardPin:
      if controller.getPin().len == PINLengthForStatusApp:
        return createState(StateType.RepeatPin, self.flowType, self)