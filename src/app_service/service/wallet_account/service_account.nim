  proc storeWatchOnlyAccount(self: Service, account: WalletAccountDto) =
    if self.watchOnlyAccounts.hasKey(account.address):
      error "trying to store an already existing watch only account"
      return
    self.watchOnlyAccounts[account.address] = account

proc storeKeypair(self: Service, keypair: KeypairDto) =
  if keypair.keyUid.len == 0:
    error "trying to store a keypair with empty keyUid"
    return
  if self.keypairs.hasKey(keypair.keyUid):
    error "trying to store an already existing keypair"
    return
  self.keypairs[keypair.keyUid] = keypair

# replaces only keypair/accounts fields that could be changed
proc replaceKeypair(self: Service, keypair: KeypairDto) =
  if keypair.keyUid.len == 0:
    error "trying to replace a keypair with empty keyUid"
    return
  if not self.keypairs.hasKey(keypair.keyUid):
    error "trying to replace a non existing keypair"
    return
  var localKp = self.keypairs[keypair.keyUid]
  localKp.name = keypair.name
  localKp.lastUsedDerivationIndex = keypair.lastUsedDerivationIndex
  localKp.syncedFrom = keypair.syncedFrom
  localKp.removed = keypair.removed
  localKp.keycards = keypair.keycards
  for locAcc in localKp.accounts:
    for acc in keypair.accounts:
      if cmpIgnoreCase(locAcc.address, acc.address) != 0:
        continue
      locAcc.name = acc.name
      locAcc.colorId = acc.colorId
      locAcc.emoji = acc.emoji
      locAcc.operable = acc.operable
      locAcc.removed = acc.removed
      locAcc.prodPreferredChainIds = acc.prodPreferredChainIds
      locAcc.testPreferredChainIds = acc.testPreferredChainIds
      break

proc storeAccountToKeypair(self: Service, account: WalletAccountDto) =
  if account.keyUid.len == 0:
    error "trying to store a keypair related account with empty keyUid"
    return
  if self.keypairs[account.keyUid].accounts.filter(acc => cmpIgnoreCase(acc.address, account.address) == 0).len != 0:
    error "trying to store an already existing keytpair related account"
    return
  self.keypairs[account.keyUid].accounts.add(account)

proc getKeypairs*(self: Service): seq[KeypairDto] =
  return toSeq(self.keypairs.values)

proc getKeypairByKeyUid*(self: Service, keyUid: string): KeypairDto =
  if not self.keypairs.hasKey(keyUid):
    return
  return self.keypairs[keyUid]

proc getKeypairByAccountAddress*(self: Service, address: string): KeypairDto =
  for _, kp in self.keypairs:
    for acc in kp.accounts:
      if cmpIgnoreCase(acc.address, address) == 0:
        return kp

proc getWatchOnlyAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.watchOnlyAccounts.values)

proc getWatchOnlyAccountByAddress*(self: Service, address: string): WalletAccountDto =
  if not self.watchOnlyAccounts.hasKey(address):
    return
  return self.watchOnlyAccounts[address]

proc getAccountByAddress*(self: Service, address: string): WalletAccountDto =
  result = self.getWatchOnlyAccountByAddress(address)
  if not result.isNil:
    return
  for _, kp in self.keypairs:
    let accounts = kp.accounts.filter(acc => cmpIgnoreCase(acc.address, address) == 0)
    if accounts.len == 1:
      return accounts[0]

proc getAccountsByAddresses*(self: Service, addresses: seq[string]): seq[WalletAccountDto] =
  for address in addresses:
    let acc = self.getAccountByAddress(address)
    if acc.isNil:
      continue
    result.add(acc)

proc getWalletAccounts*(self: Service): seq[WalletAccountDto] =
  for _, kp in self.keypairs:
    if kp.keypairType == KeypairTypeProfile:
      for acc in kp.accounts:
        if acc.isChat:
          continue
        result.add(acc)
      continue
    result.add(kp.accounts)
  result.add(toSeq(self.watchOnlyAccounts.values))
  result.sort(walletAccountsCmp)

proc getWalletAddresses*(self: Service): seq[string] =
  return self.getWalletAccounts().map(a => a.address)

proc updateAssetsLoadingState(self: Service, address: string, loading: bool) =
  var acc = self.getAccountByAddress(address)
  if acc.isNil:
    return
  acc.assetsLoading = loading

#################################################
# TODO: remove functions below
#
# The only need for a function `getIndex` below is for switching selected account.
# Switching an account in UI by the index on which an account is stored in wallet settings service cache
# is completely wrong approach we need to handle that properly, at least by using position.
proc getIndex*(self: Service, address: string): int =
  let accounts = self.getWalletAccounts()
  for i in 0 ..< accounts.len:
    if cmpIgnoreCase(accounts[i].address, address) == 0:
      return i
# The same for `getWalletAccount`, both of them need to be removed. Parts of the app which are using them
# need refactor for sure.
proc getWalletAccount*(self: Service, accountIndex: int): WalletAccountDto =
  let accounts = self.getWalletAccounts()
  if accountIndex < 0 or accountIndex >= accounts.len:
    return
  return accounts[accountIndex]
#################################################

proc startWallet(self: Service) =
  if(not main_constants.WALLET_ENABLED):
    return
  discard backend.startWallet()

proc init*(self: Service) =
  try:
    let chainId = self.networkService.getNetworkForEns().chainId
    let woAccounts = getWatchOnlyAccountsFromDb()
    for acc in woAccounts:
      acc.ens = getEnsName(acc.address, chainId)
      self.storeWatchOnlyAccount(acc)
    let keypairs = getKeypairsFromDb()
    for kp in keypairs:
      for acc in kp.accounts:
        acc.ens = getEnsName(acc.address, chainId)
      self.storeKeypair(kp)

    let addresses = self.getWalletAddresses()
    self.buildAllTokens(addresses, store = true)
    self.checkRecentHistory(addresses)
    self.startWallet()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

  self.events.on(SignalType.Message.event) do(e: Args):
    var receivedData = MessageSignal(e)
    if receivedData.watchOnlyAccounts.len > 0:
      for acc in receivedData.watchOnlyAccounts:
        self.handleWalletAccount(acc)
    if receivedData.keypairs.len > 0:
      for kp in receivedData.keypairs:
        self.handleKeypair(kp)
    if receivedData.accountsPositions.len > 0:
      self.updateAccountsPositions()
      self.events.emit(SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED, Args())

  self.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    case data.eventType:
      of "wallet-tick-reload":
        let addresses = self.getWalletAddresses()
        self.buildAllTokens(addresses, store = true)
        self.checkRecentHistory(addresses)

  self.events.on(SIGNAL_CURRENCY_UPDATED) do(e:Args):
    self.buildAllTokens(self.getWalletAddresses(), store = true)

  self.events.on(SIGNAL_IMPORT_PARTIALLY_OPERABLE_ACCOUNTS) do(e: Args):
    let args = ImportAccountsArgs(e)
    self.importPartiallyOperableAccounts(args.keyUid, args.password)

proc addNewKeypairsAccountsToLocalStoreAndNotify(self: Service, notify: bool = true) =
  let chainId = self.networkService.getNetworkForEns().chainId
  let allLocalAaccounts = self.getWalletAccounts()
  # check if there is new watch only account
  let woAccountsDb = getWatchOnlyAccountsFromDb()
  for woAccDb in woAccountsDb:
    var found = false
    for localAcc in allLocalAaccounts:
      if cmpIgnoreCase(localAcc.address, woAccDb.address) == 0:
        found = true
        break
    if found:
      continue
    woAccDb.ens = getEnsName(woAccDb.address, chainId)
    self.storeWatchOnlyAccount(woAccDb)
    self.buildAllTokens(@[woAccDb.address], store = true)
    if notify:
      self.events.emit(SIGNAL_WALLET_ACCOUNT_SAVED, AccountArgs(account: woAccDb))
  # check if there is new keypair or any account added to an existing keypair
  let keypairsDb = getKeypairsFromDb()
  for kpDb in keypairsDb:
    var localKp = self.getKeypairByKeyUid(kpDb.keyUid)
    if localKp.isNil:
      self.storeKeypair(kpDb)
      let addresses = kpDb.accounts.map(a => a.address)
      self.buildAllTokens(addresses, store = true)
      for acc in kpDb.accounts:
        acc.ens = getEnsName(acc.address, chainId)
        if acc.isChat:
          continue
        if notify:
          self.events.emit(SIGNAL_WALLET_ACCOUNT_SAVED, AccountArgs(account: acc))
    else:
      for accDb in kpDb.accounts:
        var found = false
        for localAcc in allLocalAaccounts:
          if cmpIgnoreCase(localAcc.address, accDb.address) == 0:
            found = true
            break
        if found:
          continue
        accDb.ens = getEnsName(accDb.address, chainId)
        self.storeAccountToKeypair(accDb)
        if accDb.isChat:
          continue
        self.buildAllTokens(@[accDb.address], store = true)
        if notify:
          self.events.emit(SIGNAL_WALLET_ACCOUNT_SAVED, AccountArgs(account: accDb))

proc removeAccountFromLocalStoreAndNotify(self: Service, address: string, notify: bool = true) =
  var acc = self.getAccountByAddress(address)
  if acc.isNil:
    return
  if acc.keyUid.len == 0:
    self.watchOnlyAccounts.del(acc.address)
  else:
    var index = -1
    for i in 0 ..< self.keypairs[acc.keyUid].accounts.len:
      if cmpIgnoreCase(self.keypairs[acc.keyUid].accounts[i].address, acc.address) == 0:
        index = i
        break
    if index == -1:
      error "cannot find account with the address to remove", address=address
      return
    self.keypairs[acc.keyUid].accounts.del(index)
    if self.keypairs[acc.keyUid].accounts.len == 0:
      self.keypairs.del(acc.keyUid)
  if notify:
    self.events.emit(SIGNAL_WALLET_ACCOUNT_DELETED, AccountArgs(account: acc))

proc updateKeypairOperabilityInLocalStoreAndNotify*(self: Service, importedKeyUids: seq[string]) =
  var updatedKeypairs: seq[KeypairDto]
  let localKeypairs = self.getKeypairs()
  for keyUid in importedKeyUids:
    var foundKp: KeypairDto = nil
    for kp in localKeypairs:
      if keyUid == kp.keyUid:
        foundKp = kp
        break
    if foundKp.isNil:
      error "there is no known keypair", keyUid=keyUid, procName="updateKeypairOperabilityInLocalStoreAndNotify"
      return
    for acc in foundKp.accounts:
      acc.operable = AccountFullyOperable
    updatedKeypairs.add(foundKp)
  if updatedKeypairs.len == 0:
    return
  self.events.emit(SIGNAL_IMPORTED_KEYPAIRS, KeypairsArgs(keypairs: updatedKeypairs))

proc updateAccountsPositions(self: Service) =
  let dbAccounts = getAccountsFromDb()
  for dbAcc in dbAccounts:
    var localAcc = self.getAccountByAddress(dbAcc.address)
    if localAcc.isNil:
      continue
    localAcc.position = dbAcc.position

proc updateAccountInLocalStoreAndNotify(self: Service, address, name, colorId, emoji: string, operable: string = "",
  positionUpdated: Option[bool] = none(bool), notify: bool = true) =
  if address.len > 0:
    var account = self.getAccountByAddress(address)
    if account.isNil:
      return
    if name.len > 0 or colorId.len > 0 or emoji.len > 0 or operable.len > 0:
      if name.len > 0 and name != account.name:
        account.name = name
      if colorId.len > 0 and colorId != account.colorId:
        account.colorId = colorId
      if emoji.len > 0 and emoji != account.emoji:
        account.emoji = emoji
      if operable.len > 0 and operable != account.operable and
        (operable == AccountNonOperable or operable == AccountPartiallyOperable or operable == AccountFullyOperable):
          account.operable = operable
      if notify:
        self.events.emit(SIGNAL_WALLET_ACCOUNT_UPDATED, AccountArgs(account: account))
  else:
    if not positionUpdated.isSome:
      return
    if positionUpdated.get:
      ## if reordering was successfully stored, we need to update local storage
      self.updateAccountsPositions()
    if notify:
      self.events.emit(SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED, Args())

proc updatePreferredSharingChainsAndNotify(self: Service, address, prodPreferredChains, testPreferredChains: string) =
  var account = self.getAccountByAddress(address)
  if account.isNil:
    error "account's address is not among known addresses: ", address=address, procName="updatePreferredSharingChainsAndNotify"
    return
  if testPreferredChains.len > 0 and testPreferredChains != account.testPreferredChainIds:
    account.testPreferredChainIds = testPreferredChains
  if prodPreferredChains.len > 0 and prodPreferredChains != account.prodPreferredChainIds:
    account.prodPreferredChainIds = prodPreferredChains
  self.events.emit(SIGNAL_WALLET_ACCOUNT_PREFERRED_SHARING_CHAINS_UPDATED, AccountArgs(account: account))

## if password is not provided local keystore file won't be created
proc addWalletAccount*(self: Service, password: string, doPasswordHashing: bool, name, address, path, publicKey,
  keyUid, accountType, colorId, emoji: string, hideFromTotalBalance: bool): string =
  try:
    var response: RpcResponse[JsonNode]
    if password.len == 0:
      response = status_go_accounts.addAccountWithoutKeystoreFileCreation(name, address, path, publicKey, keyUid,
        accountType, colorId, emoji, hideFromTotalBalance)
    else:
      var finalPassword = password
      if doPasswordHashing:
        finalPassword = utils.hashPassword(password)
      response = status_go_accounts.addAccount(finalPassword, name, address, path, publicKey, keyUid, accountType,
        colorId, emoji, hideFromTotalBalance)
    if not response.error.isNil:
      error "status-go error", procName="addWalletAccount", errCode=response.error.code, errDesription=response.error.message
      return response.error.message
    self.addNewKeypairsAccountsToLocalStoreAndNotify()
    return ""
  except Exception as e:
    error "error: ", procName="addWalletAccount", errName=e.name, errDesription=e.msg
    return e.msg

## Mandatory fields for account: `address`, `keyUid`, `walletType`, `path`, `publicKey`, `name`, `emoji`, `colorId`
proc addNewPrivateKeyKeypair*(self: Service, privateKey, password: string, doPasswordHashing: bool,
  keyUid, keypairName, rootWalletMasterKey: string, account: WalletAccountDto): string =
  if password.len == 0:
    let err = "for adding new private key account, password must be provided"
    error "error", err
    return err
  var finalPassword = password
  if doPasswordHashing:
    finalPassword = utils.hashPassword(password)
  try:
    var response = status_go_accounts.importPrivateKey(privateKey, finalPassword)
    if not response.error.isNil:
      error "status-go error importing private key", procName="addNewPrivateKeyKeypair", errCode=response.error.code, errDesription=response.error.message
      return response.error.message
    response = status_go_accounts.addKeypair(finalPassword, keyUid, keypairName, KeypairTypeKey, rootWalletMasterKey, @[account])
    if not response.error.isNil:
      error "status-go error adding keypair", procName="addNewPrivateKeyKeypair", errCode=response.error.code, errDesription=response.error.message
      return response.error.message
    self.addNewKeypairsAccountsToLocalStoreAndNotify()
    return ""
  except Exception as e:
    error "error: ", procName="addNewPrivateKeyKeypair", errName=e.name, errDesription=e.msg
    return e.msg

proc makePrivateKeyKeypairFullyOperable*(self: Service, keyUid, privateKey, password: string, doPasswordHashing: bool): string =
  if password.len == 0:
    let err = "for making a private key keypair fully operable, password must be provided"
    error "error", err
    return err
  var finalPassword = password
  if doPasswordHashing:
    finalPassword = utils.hashPassword(password)
  try:
    var response = status_go_accounts.makePrivateKeyKeypairFullyOperable(privateKey, finalPassword)
    if not response.error.isNil:
      error "status-go error", procName="makePrivateKeyKeypairFullyOperable", errCode=response.error.code, errDesription=response.error.message
      return response.error.message
    self.updateKeypairOperabilityInLocalStoreAndNotify(@[keyUid])
    return ""
  except Exception as e:
    error "error: ", procName="makePrivateKeyKeypairFullyOperable", errName=e.name, errDesription=e.msg
    return e.msg

## Mandatory fields for all accounts: `address`, `keyUid`, `walletType`, `path`, `publicKey`, `name`, `emoji`, `colorId`
proc addNewSeedPhraseKeypair*(self: Service, seedPhrase, password: string, doPasswordHashing: bool,
  keyUid, keypairName, rootWalletMasterKey: string, accounts: seq[WalletAccountDto]): string =
  var finalPassword = password
  if password.len > 0 and doPasswordHashing:
    finalPassword = utils.hashPassword(password)
  try:
    if seedPhrase.len > 0 and password.len > 0:
      let response = status_go_accounts.importMnemonic(seedPhrase, finalPassword)
      if not response.error.isNil:
        error "status-go error importing private key", procName="addNewSeedPhraseKeypair", errCode=response.error.code, errDesription=response.error.message
        return response.error.message
    let response = status_go_accounts.addKeypair(finalPassword, keyUid, keypairName, KeypairTypeSeed, rootWalletMasterKey, accounts)
    if not response.error.isNil:
      error "status-go error adding keypair", procName="addNewSeedPhraseKeypair", errCode=response.error.code, errDesription=response.error.message
      return response.error.message
    for i in 0 ..< accounts.len:
      self.addNewKeypairsAccountsToLocalStoreAndNotify()
    return ""
  except Exception as e:
    error "error: ", procName="addNewSeedPhraseKeypair", errName=e.name, errDesription=e.msg
    return e.msg

proc makeSeedPhraseKeypairFullyOperable*(self: Service, keyUid, mnemonic, password: string, doPasswordHashing: bool): string =
  if password.len == 0:
    let err = "for making a private key keypair fully operable, password must be provided"
    error "error", err
    return err
  var finalPassword = password
  if doPasswordHashing:
    finalPassword = utils.hashPassword(password)
  try:
    var response = status_go_accounts.makeSeedPhraseKeypairFullyOperable(mnemonic, finalPassword)
    if not response.error.isNil:
      error "status-go error", procName="makeSeedPhraseKeypairFullyOperable", errCode=response.error.code, errDesription=response.error.message
      return response.error.message
    self.updateKeypairOperabilityInLocalStoreAndNotify(@[keyUid])
    return ""
  except Exception as e:
    error "error: ", procName="makeSeedPhraseKeypairFullyOperable", errName=e.name, errDesription=e.msg
    return e.msg

proc makePartiallyOperableAccoutsFullyOperable(self: Service, password: string, doPasswordHashing: bool) =
  if password.len == 0:
    error "for making partially operable accounts a fully operable, password must be provided"
    return
  var finalPassword = password
  if doPasswordHashing:
    finalPassword = utils.hashPassword(password)
  try:
    var response = status_go_accounts.makePartiallyOperableAccoutsFullyOperable(finalPassword)
    if not response.error.isNil:
      error "status-go error", procName="makePartiallyOperableAccoutsFullyOperable", errCode=response.error.code, errDesription=response.error.message
      return
    let affectedAccounts = map(response.result.getElems(), x => x.getStr())
    for acc in affectedAccounts:
      self.updateAccountInLocalStoreAndNotify(acc, name = "", colorId = "", emoji = "", operable = AccountFullyOperable)
  except Exception as e:
    error "error: ", procName="makeSeedPhraseKeypairFullyOperable", errName=e.name, errDesription=e.msg

proc onNonProfileKeycardKeypairMigratedToApp*(self: Service, response: string) {.slot.} =
  var data = KeycardArgs(
    success: false,
    keycard: KeycardDto()
  )
  try:
    let responseObj = response.parseJson
    discard responseObj.getProp("success", data.success)
    discard responseObj.getProp("keyUid", data.keycard.keyUid)
    let kp = self.getKeypairByKeyUid(data.keycard.keyUid)
    if kp.isNil:
      data.success = false
    else:
      kp.keycards = @[]
  except Exception as e:
    error "error handilng migrated keycard response", errDesription=e.msg
  self.events.emit(SIGNAL_ALL_KEYCARDS_DELETED, data)

proc migrateNonProfileKeycardKeypairToAppAsync*(self: Service, keyUid, seedPhrase, password: string, doPasswordHashing: bool) =
  var finalPassword = password
  if doPasswordHashing:
    finalPassword = utils.hashPassword(password)
  let arg = MigrateNonProfileKeycardKeypairToAppTaskArg(
    tptr: cast[ByteAddress](migrateNonProfileKeycardKeypairToAppTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onNonProfileKeycardKeypairMigratedToApp",
    keyUid: keyUid,
    seedPhrase: seedPhrase,
    password: finalPassword
  )
  self.threadpool.start(arg)

proc getRandomMnemonic*(self: Service): string =
  try:
    let response = status_go_accounts.getRandomMnemonic()
    if not response.error.isNil:
      error "status-go error", procName="getRandomMnemonic", errCode=response.error.code, errDesription=response.error.message
      return ""
    return response.result.getStr
  except Exception as e:
    error "error: ", procName="getRandomMnemonic", errName=e.name, errDesription=e.msg
    return ""

proc deleteAccount*(self: Service, address: string) =
  try:
    let response = status_go_accounts.deleteAccount(address)
    if not response.error.isNil:
      error "status-go error", procName="deleteAccount", errCode=response.error.code, errDesription=response.error.message
      return
    self.removeAccountFromLocalStoreAndNotify(address)
  except Exception as e:
    error "error: ", procName="deleteAccount", errName = e.name, errDesription = e.msg

proc deleteKeypair*(self: Service, keyUid: string) =
  try:
    let kp = self.getKeypairByKeyUid(keyUid)
    if kp.isNil:
      error "there is no known keypair", keyUid=keyUid, procName="deleteKeypair"
      return
    let response = status_go_accounts.deleteKeypair(keyUid)
    if not response.error.isNil:
      error "status-go error", procName="deleteKeypair", errCode=response.error.code, errDesription=response.error.message
      return
    self.updateAccountsPositions()
    let addresses = kp.accounts.map(a => a.address)
    for address in addresses:
      self.removeAccountFromLocalStoreAndNotify(address)
    self.events.emit(SIGNAL_KEYPAIR_DELETED, KeypairArgs(keyPairName: kp.name))
  except Exception as e:
    error "error: ", procName="deleteKeypair", errName = e.name, errDesription = e.msg

proc updateCurrency*(self: Service, newCurrency: string) =
  discard self.settingsService.saveCurrency(newCurrency)

proc setNetworksState*(self: Service, chainIds: seq[int], enabled: bool) =
  self.networkService.setNetworksState(chainIds, enabled)
  self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, Args())

proc toggleTestNetworksEnabled*(self: Service) =
  discard self.settingsService.toggleTestNetworksEnabled()
  let addresses = self.getWalletAddresses()
  self.buildAllTokens(addresses, store = true)
  self.tokenService.loadData()
  self.checkRecentHistory(addresses)
  self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, Args())

proc toggleIsSepoliaEnabled*(self: Service) =
  discard self.settingsService.toggleIsSepoliaEnabled()
  self.networkService.resetNetworks()
  let addresses = self.getWalletAddresses()
  self.buildAllTokens(addresses, store = true)
  self.tokenService.loadData()
  self.checkRecentHistory(addresses)
  self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, Args())

proc updateWalletAccount*(self: Service, address: string, accountName: string, colorId: string, emoji: string): bool =
  try:
    var account = self.getAccountByAddress(address)
    if account.isNil:
      error "account's address is not among known addresses: ", address=address, procName="updateWalletAccount"
      return false
    let response = status_go_accounts.updateAccount(accountName, account.address, account.path, account.publicKey,
      account.keyUid, account.walletType, colorId, emoji, account.isWallet, account.isChat, account.prodPreferredChainIds, account.testPreferredChainIds, account.hideFromTotalBalance)
    if not response.error.isNil:
      error "status-go error", procName="updateWalletAccount", errCode=response.error.code, errDesription=response.error.message
      return false
    self.updateAccountInLocalStoreAndNotify(address, accountName, colorId, emoji)
    return true
  except Exception as e:
    error "error: ", procName="updateWalletAccount", errName=e.name, errDesription=e.msg
  return false

proc updateWalletAccountProdPreferredChains*(self: Service, address, preferredChainIds: string): bool =
  try:
    var account = self.getAccountByAddress(address)
    if account.isNil:
      error "account's address is not among known addresses: ", address=address, procName="updateWalletAccountProdPreferredChains"
      return false
    let response = status_go_accounts.updateAccount(account.name, account.address, account.path, account.publicKey,
      account.keyUid, account.walletType, account.colorId, account.emoji, account.isWallet, account.isChat, preferredChainIds, account.testPreferredChainIds, account.hideFromTotalBalance)
    if not response.error.isNil:
      error "status-go error", procName="updateWalletAccountProdPreferredChains", errCode=response.error.code, errDesription=response.error.message
      return false
    self.updatePreferredSharingChainsAndNotify(address, prodPreferredChains = preferredChainIds, testPreferredChains = "")
    return true
  except Exception as e:
    error "error: ", procName="updateWalletAccountProdPreferredChains", errName=e.name, errDesription=e.msg
  return false

proc updateWalletAccountTestPreferredChains*(self: Service, address, preferredChainIds: string): bool =
  try:
    var account = self.getAccountByAddress(address)
    if account.isNil:
      error "account's address is not among known addresses: ", address=address, procName="updateWalletAccountTestPreferredChains"
      return false
    let response = status_go_accounts.updateAccount(account.name, account.address, account.path, account.publicKey,
      account.keyUid, account.walletType, account.colorId, account.emoji, account.isWallet, account.isChat, account.prodPreferredChainIds, preferredChainIds, account.hideFromTotalBalance)
    if not response.error.isNil:
      error "status-go error", procName="updateWalletAccountTestPreferredChains", errCode=response.error.code, errDesription=response.error.message
      return false
    self.updatePreferredSharingChainsAndNotify(address, prodPreferredChains = "", testPreferredChains = preferredChainIds)
    return true
  except Exception as e:
    error "error: ", procName="updateWalletAccountTestPreferredChains", errName=e.name, errDesription=e.msg
  return false

proc updateWatchAccountHiddenFromTotalBalance*(self: Service, address: string, hideFromTotalBalance: bool): bool =
  try:
    var account = self.getAccountByAddress(address)
    if account.isNil:
      error "account's address is not among known addresses: ", address=address, procName="updateWatchAccountHiddenFromTotalBalance"
      return false
    let response = status_go_accounts.updateAccount(account.name, account.address, account.path, account.publicKey,
      account.keyUid, account.walletType, account.colorId, account.emoji, account.isWallet, account.isChat, account.prodPreferredChainIds, account.testPreferredChainIds, hideFromTotalBalance)
    if not response.error.isNil:
      error "status-go error", procName="updateWatchAccountHiddenFromTotalBalance", errCode=response.error.code, errDesription=response.error.message
      return false
    if hideFromTotalBalance != account.hideFromTotalBalance:
      account.hideFromTotalBalance = hideFromTotalBalance
    self.events.emit(SIGNAL_WALLET_ACCOUNT_HIDDEN_UPDATED, AccountArgs(account: account))
    return true
  except Exception as e:
    error "error: ", procName="updateWatchAccountHiddenFromTotalBalance", errName=e.name, errDesription=e.msg
  return false

proc moveAccountFinally*(self: Service, fromPosition: int, toPosition: int) =
  var updated = false
  try:
    let response = backend.moveWalletAccount(fromPosition, toPosition)
    if not response.error.isNil:
      error "status-go error", procName="moveAccountFinally", errCode=response.error.code, errDesription=response.error.message
    updated = true
  except Exception as e:
    error "error: ", procName="moveAccountFinally", errName=e.name, errDesription=e.msg
  self.updateAccountInLocalStoreAndNotify(address = "", name = "", colorId = "", emoji = "", operable = "", some(updated))

proc updateKeypairName*(self: Service, keyUid: string, name: string) =
  try:
    let kp = self.getKeypairByKeyUid(keyUid)
    if kp.isNil:
      error "there is no known keypair", keyUid=keyUid, procName="updateKeypairName"
      return
    let response = backend.updateKeypairName(keyUid, name)
    if not response.error.isNil:
      error "status-go error", procName="updateKeypairName", errCode=response.error.code, errDesription=response.error.message
      return
    var data = KeypairArgs(
      keypair: KeypairDto(
        keyUid: keyUid,
        name: name
        ),
      oldKeypairName: kp.name
      )
    kp.name = name
    self.events.emit(SIGNAL_KEYPAIR_NAME_CHANGED, data)
  except Exception as e:
    error "error: ", procName="updateKeypairName", errName=e.name, errDesription=e.msg

proc fetchDerivedAddresses*(self: Service, password: string, derivedFrom: string, paths: seq[string], hashPassword: bool) =
  let arg = FetchDerivedAddressesTaskArg(
    password: if hashPassword: utils.hashPassword(password) else: password,
    derivedFrom: derivedFrom,
    paths: paths,
    tptr: cast[ByteAddress](fetchDerivedAddressesTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onDerivedAddressesFetched",
  )
  self.threadpool.start(arg)

proc onDerivedAddressesFetched*(self: Service, jsonString: string) {.slot.} =
  let response = parseJson(jsonString)
  var derivedAddress: seq[DerivedAddressDto] = @[]
  derivedAddress = response["derivedAddresses"].getElems().map(x => x.toDerivedAddressDto())
  let error = response["error"].getStr()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESSES_FETCHED, DerivedAddressesArgs(
    derivedAddresses: derivedAddress,
    error: error
  ))

proc fetchDerivedAddressesForMnemonic*(self: Service, mnemonic: string, paths: seq[string])=
  let arg = FetchDerivedAddressesForMnemonicTaskArg(
    mnemonic: mnemonic,
    paths: paths,
    tptr: cast[ByteAddress](fetchDerivedAddressesForMnemonicTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onDerivedAddressesForMnemonicFetched",
  )
  self.threadpool.start(arg)

proc onDerivedAddressesForMnemonicFetched*(self: Service, jsonString: string) {.slot.} =
  let response = parseJson(jsonString)
  var derivedAddress: seq[DerivedAddressDto] = @[]
  derivedAddress = response["derivedAddresses"].getElems().map(x => x.toDerivedAddressDto())
  let error = response["error"].getStr()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESSES_FROM_MNEMONIC_FETCHED, DerivedAddressesArgs(
    derivedAddresses: derivedAddress,
    error: error
  ))

proc fetchDetailsForAddresses*(self: Service, uniqueId: string, addresses: seq[string]) =
  let network = self.networkService.getNetworkForActivityCheck()
  let arg = FetchDetailsForAddressesTaskArg(
    uniqueId: uniqueId,
    chainId: network.chainId,
    addresses: addresses,
    tptr: cast[ByteAddress](fetchDetailsForAddressesTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onAddressDetailsFetched",
  )
  self.threadpool.start(arg)

proc onAddressDetailsFetched*(self: Service, jsonString: string) {.slot.} =
  var data = DerivedAddressesArgs()
  try:
    let response = parseJson(jsonString)
    data.uniqueId = response["uniqueId"].getStr()
    let addrDto = response{"details"}.toDerivedAddressDto()
    data.derivedAddresses.add(addrDto)
    data.error = response["error"].getStr()
  except Exception as e:
    error "error: ", procName="fetchAddressDetails", errName = e.name, errDesription = e.msg
    data.error = e.msg
  self.events.emit(SIGNAL_WALLET_ACCOUNT_ADDRESS_DETAILS_FETCHED, data)

proc handleWalletAccount(self: Service, account: WalletAccountDto, notify: bool = true) =
  if account.removed:
    self.updateAccountsPositions()
    self.removeAccountFromLocalStoreAndNotify(account.address, notify)
  else:
    var localAcc = self.getAccountByAddress(account.address)
    if not localAcc.isNil:
      self.updateAccountInLocalStoreAndNotify(account.address, account.name, account.colorId, account.emoji,
        account.operable, none(bool), notify)
    else:
      self.addNewKeypairsAccountsToLocalStoreAndNotify(notify)

proc handleKeypair(self: Service, keypair: KeypairDto) =
  let localKp = self.getKeypairByKeyUid(keypair.keyUid)
  if not localKp.isNil:
    # sotore only keypair fields which may change
    localKp.name = keypair.name
    localKp.lastUsedDerivationIndex = keypair.lastUsedDerivationIndex
    localKp.syncedFrom = keypair.syncedFrom
    localKp.keycards = keypair.keycards
    # - first remove removed accounts from the UI
    let addresses = localKp.accounts.map(a => a.address)
    for address in addresses:
      let accAddress = address
      if keypair.accounts.filter(a => cmpIgnoreCase(a.address, accAddress) == 0).len == 0:
        self.handleWalletAccount(WalletAccountDto(address: accAddress, removed: true), notify = false)
    # - second add/update new/existing accounts
    for acc in keypair.accounts:
      self.handleWalletAccount(acc, notify = false)
  else:
    self.addNewKeypairsAccountsToLocalStoreAndNotify(notify = false)

  # notify all interested parts about the keypair change
  self.events.emit(SIGNAL_KEYPAIR_SYNCED, KeypairArgs(keypair: keypair))

proc onFetchChainIdForUrl*(self: Service, jsonString: string) {.slot.} =
  let response = parseJson(jsonString)
  self.events.emit(SIGNAL_WALLET_ACCOUNT_CHAIN_ID_FOR_URL_FETCHED, ChainIdForUrlArgs(
    chainId: response{"chainId"}.getInt,
    success: response{"success"}.getBool,
    url: response{"url"}.getStr,
    isMainUrl: response{"isMainUrl"}.getBool
  ))

proc fetchChainIdForUrl*(self: Service, url: string, isMainUrl: bool) =
  let arg = FetchChainIdForUrlTaskArg(
    tptr: cast[ByteAddress](fetchChainIdForUrlTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onFetchChainIdForUrl",
    url: url,
    isMainUrl: isMainUrl
  )
  self.threadpool.start(arg)

proc getEnabledChainIds*(self: Service): seq[int] =
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)

proc getCurrencyFormat*(self: Service, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc areTestNetworksEnabled*(self: Service): bool =
  return self.settingsService.areTestNetworksEnabled()

proc isSepoliaEnabled*(self: Service): bool =
  return self.settingsService.isSepoliaEnabled()

proc hasPairedDevices*(self: Service): bool =
  return hasPairedDevices()

proc importPartiallyOperableAccounts(self: Service, keyUid: string, password: string) =
  ## Whenever user provides a password/pin we need to make all partially operable accounts (if any exists) a fully operable.
  if  keyUid != singletonInstance.userProfile.getKeyUid():
    return
  self.makePartiallyOperableAccoutsFullyOperable(password, not singletonInstance.userProfile.getIsKeycardUser())
