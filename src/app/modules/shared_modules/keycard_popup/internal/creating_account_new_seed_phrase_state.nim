type
  CreatingAccountNewSeedPhraseState* = ref object of State
    paths: seq[string]
    addresses: seq[string]
    addingAccountsToWalletDone: bool
    addingAccountsToWalletOk: bool
    addingMigratedKeypairDone: bool
    addingMigratedKeypairOk: bool

proc newCreatingAccountNewSeedPhraseState*(flowType: FlowType, backState: State): CreatingAccountNewSeedPhraseState =
  result = CreatingAccountNewSeedPhraseState()
  result.setup(flowType, StateType.CreatingAccountNewSeedPhrase, backState)
  result.addingAccountsToWalletDone = false
  result.addingAccountsToWalletOk = false
  result.addingMigratedKeypairDone = false
  result.addingMigratedKeypairOk = false

proc delete*(self: CreatingAccountNewSeedPhraseState) =
  self.State.delete

proc resolvePaths(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  let kpForPRocessing = controller.getKeyPairForProcessing()
  var i = 0
  for account in kpForPRocessing.getAccountsModel().getItems():
    account.setPath(PATH_WALLET_ROOT & "/" & $i)
    self.paths.add(account.getPath())
    i.inc

proc resolveAddressesForPaths(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  let kpForPRocessing = controller.getKeyPairForProcessing()
  let generatedAccount = controller.generateAccountsFromSeedPhrase(controller.getSeedPhrase(), self.paths)
  for account in kpForPRocessing.getAccountsModel().getItems():
    if not generatedAccount.derivedAccounts.derivations.hasKey(account.getPath()):
      return
    kpForPRocessing.setDerivedFrom(generatedAccount.address)
    let accDetails = generatedAccount.derivedAccounts.derivations[account.getPath()]
    account.setAddress(accDetails.address)
    account.setPubKey(accDetails.publicKey)
    self.addresses.add(accDetails.address)

proc addAccountsToWallet(self: CreatingAccountNewSeedPhraseState, controller: Controller): bool =
  let kpForPRocessing = controller.getKeyPairForProcessing()
  for account in kpForPRocessing.getAccountsModel().getItems():
    if not controller.addWalletAccount(name = account.getName(), 
      address = account.getAddress(), 
      path = account.getPath(), 
      addressAccountIsDerivedFrom = kpForPRocessing.getDerivedFrom(), 
      publicKey = account.getPubKey(), 
      keyUid = kpForPRocessing.getKeyUid(), 
      accountType = if account.getPath() == PATH_DEFAULT_WALLET: SEED else: GENERATED,
      color = account.getColor(), 
      emoji = account.getEmoji()):
      return false
  return true

proc doMigration(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  let kpForPRocessing = controller.getKeyPairForProcessing()
  var kpDto = KeyPairDto(keycardUid: controller.getKeycardUid(),
    keycardName: kpForPRocessing.getName(),
    keycardLocked: false,
    accountsAddresses: self.addresses,
    keyUid: kpForPRocessing.getKeyUid())
  controller.addMigratedKeyPair(kpDto)

proc runStoreMetadataFlow(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  let kpForPRocessing = controller.getKeyPairForProcessing()
  controller.runStoreMetadataFlow(kpForPRocessing.getName(), controller.getPin(), self.paths)

method executePrePrimaryStateCommand*(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if not self.addingAccountsToWalletDone:
      self.addingAccountsToWalletDone = true
      self.resolvePaths(controller)
      self.resolveAddressesForPaths(controller)
      if self.paths.len != self.addresses.len:
        return
      self.addingAccountsToWalletOk = self.addAccountsToWallet(controller)
      if self.addingAccountsToWalletOk:
        self.doMigration(controller)

method executePreSecondaryStateCommand*(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  ## Secondary action is called after each async action during migration process. 
  if not self.addingMigratedKeypairDone:
    self.addingMigratedKeypairDone = true
    self.addingMigratedKeypairOk = controller.getAddingMigratedKeypairSuccess()
    if self.addingMigratedKeypairOk:
      self.runStoreMetadataFlow(controller)

method getNextPrimaryState*(self: CreatingAccountNewSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if self.addingAccountsToWalletDone and not self.addingAccountsToWalletOk:
      return createState(StateType.CreatingAccountNewSeedPhraseFailure, self.flowType, nil)

method getNextSecondaryState*(self: CreatingAccountNewSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if self.addingMigratedKeypairDone and not self.addingMigratedKeypairOk:
      return createState(StateType.CreatingAccountNewSeedPhraseFailure, self.flowType, nil)

method resolveKeycardNextState*(self: CreatingAccountNewSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len == 0:
        return createState(StateType.CreatingAccountNewSeedPhraseSuccess, self.flowType, nil)