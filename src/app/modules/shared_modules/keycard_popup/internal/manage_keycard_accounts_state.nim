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
  if self.flowType == FlowType.ImportFromKeycard:
    let numOfProcessedAccounts = controller.getKeyPairForProcessing().getAccountsModel().getCount()
    let totalNumOfAccountsToBeProcessed = controller.getKeyPairHelper().getAccountsModel().getCount()
    if numOfProcessedAccounts < totalNumOfAccountsToBeProcessed:
      let accountItem = controller.getKeyPairHelper().getAccountsModel().getItemAtIndex(numOfProcessedAccounts) # numOfProcessedAccounts is index of next acc which need to be processed
      if accountItem.isNil:
        # should never be here
        return createState(StateType.ImportingFromKeycardFailure, self.flowType, nil)
      controller.getKeyPairForProcessing().addAccount(newKeyPairAccountItem(name = "", 
        path = accountItem.getPath(), 
        address = accountItem.getAddress(),
        pubKey = accountItem.getPubKey()
      ))
    elif numOfProcessedAccounts == totalNumOfAccountsToBeProcessed:
      return createState(StateType.ImportingFromKeycard, self.flowType, nil)

method executePreSecondaryStateCommand*(self: ManageKeycardAccountsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase:
      controller.getKeyPairForProcessing().addAccount(newKeyPairAccountItem())

method executeCancelCommand*(self: ManageKeycardAccountsState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase or
    self.flowType == FlowType.SetupNewKeycardOldSeedPhrase or
    self.flowType == FlowType.ImportFromKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
