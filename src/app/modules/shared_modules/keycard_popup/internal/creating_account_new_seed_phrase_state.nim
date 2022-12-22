type
  CreatingAccountNewSeedPhraseState* = ref object of State
    paths: seq[string]
    addresses: seq[string]

proc newCreatingAccountNewSeedPhraseState*(flowType: FlowType, backState: State): CreatingAccountNewSeedPhraseState =
  result = CreatingAccountNewSeedPhraseState()
  result.setup(flowType, StateType.CreatingAccountNewSeedPhrase, backState)

proc delete*(self: CreatingAccountNewSeedPhraseState) =
  self.State.delete

proc resolvePaths(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  let kpForPRocessing = controller.getKeyPairForProcessing()
  var i = 0
  for account in kpForPRocessing.getAccountsModel().getItems():
    account.setPath(PATH_WALLET_ROOT & "/" & $i)
    self.paths.add(account.getPath())
    i.inc

proc findIndexForPath(self: CreatingAccountNewSeedPhraseState, path: string): int =
  var ind = -1
  for p in self.paths:
    ind.inc
    if p == path:
      return ind
  return ind

proc resolveAddresses(self: CreatingAccountNewSeedPhraseState, controller: Controller, keycardEvent: KeycardEvent): bool =
  if keycardEvent.generatedWalletAccounts.len != self.paths.len:
    return false
  let kpForPRocessing = controller.getKeyPairForProcessing()
  for account in kpForPRocessing.getAccountsModel().getItems():
    let index = self.findIndexForPath(account.getPath())
    if index == -1:
      ## should never be here
      return false
    kpForPRocessing.setDerivedFrom(keycardEvent.masterKeyAddress)
    account.setAddress(keycardEvent.generatedWalletAccounts[index].address)
    account.setPubKey(keycardEvent.generatedWalletAccounts[index].publicKey)
    self.addresses.add(keycardEvent.generatedWalletAccounts[index].address)
  return true

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
    self.resolvePaths(controller)
    controller.runDeriveAccountFlow(bip44Paths = self.paths, controller.getPin())

method executePreSecondaryStateCommand*(self: CreatingAccountNewSeedPhraseState, controller: Controller) =
  ## Secondary action is called after each async action during migration process, in this case after `addMigratedKeyPair`. 
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if controller.getAddingMigratedKeypairSuccess():
      self.runStoreMetadataFlow(controller)

method getNextSecondaryState*(self: CreatingAccountNewSeedPhraseState, controller: Controller): State =
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if not controller.getAddingMigratedKeypairSuccess():
      return createState(StateType.CreatingAccountNewSeedPhraseFailure, self.flowType, nil)

method resolveKeycardNextState*(self: CreatingAccountNewSeedPhraseState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresenceAndResolveNextState(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.SetupNewKeycardNewSeedPhrase:
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.ExportPublic:
        if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
          keycardEvent.error.len == 0:
            if not self.resolveAddresses(controller, keycardEvent):
              return createState(StateType.CreatingAccountNewSeedPhraseFailure, self.flowType, nil)
            if not self.addAccountsToWallet(controller):
              return createState(StateType.CreatingAccountNewSeedPhraseFailure, self.flowType, nil)
            self.doMigration(controller)
            return nil # returning nil, cause we need to remain in this state
    if controller.getCurrentKeycardServiceFlow() == KCSFlowType.StoreMetadata:
      if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
        keycardEvent.error.len == 0:
          return createState(StateType.CreatingAccountNewSeedPhraseSuccess, self.flowType, nil)
      return createState(StateType.CreatingAccountNewSeedPhraseSuccess, self.flowType, nil)