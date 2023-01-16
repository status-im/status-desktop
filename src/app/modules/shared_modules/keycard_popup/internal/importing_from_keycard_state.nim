type
  ImportingFromKeycardState* = ref object of State
    paths: seq[string]
    addresses: seq[string]

proc newImportingFromKeycardState*(flowType: FlowType, backState: State): ImportingFromKeycardState =
  result = ImportingFromKeycardState()
  result.setup(flowType, StateType.ImportingFromKeycard, backState)

proc delete*(self: ImportingFromKeycardState) =
  self.State.delete

proc addAccountsToWallet(self: ImportingFromKeycardState, controller: Controller): bool =
  let kpForProcessing = controller.getKeyPairForProcessing()
  let kpHelper = controller.getKeyPairHelper()
  for account in kpForProcessing.getAccountsModel().getItems():
    self.addresses.add(account.getAddress())
    if not controller.addWalletAccount(name = account.getName(), 
      address = account.getAddress(), 
      path = account.getPath(), 
      addressAccountIsDerivedFrom = kpForProcessing.getDerivedFrom(), 
      publicKey = account.getPubKey(), 
      keyUid = kpForProcessing.getKeyUid(), 
      accountType = if account.getPath() == PATH_DEFAULT_WALLET: SEED else: GENERATED,
      color = account.getColor(), 
      emoji = account.getEmoji()):
        return false
  return true

proc doMigration(self: ImportingFromKeycardState, controller: Controller) =
  let kpForProcessing = controller.getKeyPairForProcessing()
  var kpDto = KeyPairDto(keycardUid: controller.getKeycardUid(),
    keycardName: kpForProcessing.getName(),
    keycardLocked: false,
    accountsAddresses: self.addresses,
    keyUid: kpForProcessing.getKeyUid())
  controller.addMigratedKeyPair(kpDto)

method getNextPrimaryState*(self: ImportingFromKeycardState, controller: Controller): State =
  if self.flowType == FlowType.ImportFromKeycard:
    if not self.addAccountsToWallet(controller):
      return createState(StateType.ImportingFromKeycardFailure, self.flowType, nil)
    self.doMigration(controller)
    return nil

method getNextSecondaryState*(self: ImportingFromKeycardState, controller: Controller): State =
  if self.flowType == FlowType.ImportFromKeycard:
    if controller.getAddingMigratedKeypairSuccess():
      return createState(StateType.ImportingFromKeycardSuccess, self.flowType, nil)
    return createState(StateType.ImportingFromKeycardFailure, self.flowType, nil)