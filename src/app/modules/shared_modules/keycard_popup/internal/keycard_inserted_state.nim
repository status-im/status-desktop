type
  KeycardInsertedState* = ref object of State

proc newKeycardInsertedState*(flowType: FlowType, backState: State): KeycardInsertedState =
  result = KeycardInsertedState()
  result.setup(flowType, StateType.KeycardInserted, backState)

proc delete*(self: KeycardInsertedState) =
  self.State.delete

method executePreBackStateCommand*(self: KeycardInsertedState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycard:
    if not self.getBackState.isNil and self.getBackState.stateType == StateType.SelectExistingKeyPair:
      controller.cancelCurrentFlow()

method getNextSecondaryState*(self: KeycardInsertedState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycard:
    if self.stateType == StateType.SelectExistingKeyPair:
      return createState(StateType.RecognizedKeycard, self.flowType, self)
    return createState(StateType.ReadingKeycard, self.flowType, self.getBackState)
  return createState(StateType.ReadingKeycard, self.flowType, nil)

method executeCancelCommand*(self: KeycardInsertedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.Sign or
    self.flowType == FlowType.UnlockKeycard or
    self.flowType == FlowType.DisplayKeycardContent or
    self.flowType == FlowType.RenameKeycard or
    self.flowType == FlowType.ChangeKeycardPin or
    self.flowType == FlowType.ChangeKeycardPuk or
    self.flowType == FlowType.ChangePairingCode or
    self.flowType == FlowType.CreateCopyOfAKeycard or
    self.flowType == FlowType.MigrateFromAppToKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
