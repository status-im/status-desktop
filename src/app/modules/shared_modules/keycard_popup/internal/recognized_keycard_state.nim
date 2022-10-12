type
  RecognizedKeycardState* = ref object of State

proc newRecognizedKeycardState*(flowType: FlowType, backState: State): RecognizedKeycardState =
  result = RecognizedKeycardState()
  result.setup(flowType, StateType.RecognizedKeycard, backState)

proc delete*(self: RecognizedKeycardState) =
  self.State.delete

method executeBackCommand*(self: RecognizedKeycardState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method getNextSecondaryState*(self: RecognizedKeycardState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset:
    if controller.containsMetadata():
      return createState(StateType.EnterPin, self.flowType, nil)
    else:
      return createState(StateType.FactoryResetConfirmation, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycard:
    return createState(StateType.CreatePin, self.flowType, self.getBackState)
  if self.flowType == FlowType.UnlockKeycard:
    return createState(StateType.UnlockKeycardOptions, self.flowType, nil)
  if self.flowType == FlowType.DisplayKeycardContent:
    return createState(StateType.EnterPin, self.flowType, nil)
  if self.flowType == FlowType.RenameKeycard:
    return createState(StateType.EnterPin, self.flowType, nil)

method executeTertiaryCommand*(self: RecognizedKeycardState, controller: Controller) =
  error "recognized state must not be canceled"