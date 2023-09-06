type
  RecognizedKeycardState* = ref object of State

proc newRecognizedKeycardState*(flowType: FlowType, backState: State): RecognizedKeycardState =
  result = RecognizedKeycardState()
  result.setup(flowType, StateType.RecognizedKeycard, backState)

proc delete*(self: RecognizedKeycardState) =
  self.State.delete

method executePreBackStateCommand*(self: RecognizedKeycardState, controller: Controller) =
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
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
      return createState(StateType.CreatePin, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    return createState(StateType.EnterSeedPhrase, self.flowType, nil)
  if self.flowType == FlowType.UnlockKeycard:
    return createState(StateType.UnlockKeycardOptions, self.flowType, nil)
  if self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      return createState(StateType.EnterPin, self.flowType, nil)

method executeCancelCommand*(self: RecognizedKeycardState, controller: Controller) =
  error "recognized state must not be canceled"