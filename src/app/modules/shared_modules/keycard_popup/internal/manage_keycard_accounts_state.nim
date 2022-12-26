type
  ManageKeycardAccountsState* = ref object of State
    success: bool

proc newManageKeycardAccountsState*(flowType: FlowType, backState: State): ManageKeycardAccountsState =
  result = ManageKeycardAccountsState()
  result.setup(flowType, StateType.ManageKeycardAccounts, backState)
  result.success = false

proc delete*(self: ManageKeycardAccountsState) =
  self.State.delete

method getNextPrimaryState*(self: ManageKeycardAccountsState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    return createState(StateType.CreatingAccountNewSeedPhrase, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
    return createState(StateType.CreatingAccountOldSeedPhrase, self.flowType, nil)

method executePreSecondaryStateCommand*(self: ManageKeycardAccountsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      controller.getKeyPairForProcessing().addAccount(newKeyPairAccountItem())

method executeCancelCommand*(self: ManageKeycardAccountsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
