import NimQml, Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils, os, times, algorithm
import web3/ethtypes

import ../settings/service as settings_service
import ../accounts/service as accounts_service
import ../token/service as token_service
import ../network/service as network_service
import ../../common/[utils]
import ../../../app/global/global_singleton

import keypair_dto, derived_address, keycard_dto

import ../../../app/core/eventemitter
import ../../../app/core/signals/types
import ../../../app/core/tasks/[qt, threadpool]
import ../../../backend/accounts as status_go_accounts
import ../../../backend/backend as backend
import ../../../backend/eth as status_go_eth
import ../../../backend/transactions as status_go_transactions
import ../../../constants as main_constants

export keypair_dto, derived_address, keycard_dto

logScope:
  topics = "wallet-account-service"

const SIGNAL_WALLET_ACCOUNT_SAVED* = "walletAccount/accountSaved"
const SIGNAL_WALLET_ACCOUNT_DELETED* = "walletAccount/accountDeleted"
const SIGNAL_WALLET_ACCOUNT_UPDATED* = "walletAccount/walletAccountUpdated"
const SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED* = "walletAccount/networkEnabledUpdated"
const SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT* = "walletAccount/tokensRebuilt"
const SIGNAL_WALLET_ACCOUNT_TOKENS_BEING_FETCHED* = "walletAccount/tokenFetching"
const SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESSES_FETCHED* = "walletAccount/derivedAddressesFetched"
const SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESSES_FROM_MNEMONIC_FETCHED* = "walletAccount/derivedAddressesFromMnemonicFetched"
const SIGNAL_WALLET_ACCOUNT_ADDRESS_DETAILS_FETCHED* = "walletAccount/addressDetailsFetched"

const SIGNAL_KEYCARDS_SYNCHRONIZED* = "keycardsSynchronized"
const SIGNAL_NEW_KEYCARD_SET* = "newKeycardSet"
const SIGNAL_KEYCARD_DELETED* = "keycardDeleted"
const SIGNAL_KEYCARD_ACCOUNTS_REMOVED* = "keycardAccountsRemoved"
const SIGNAL_KEYCARD_LOCKED* = "keycardLocked"
const SIGNAL_KEYCARD_UNLOCKED* = "keycardUnlocked"
const SIGNAL_KEYCARD_UID_UPDATED* = "keycardUidUpdated"
const SIGNAL_KEYCARD_NAME_CHANGED* = "keycardNameChanged"

var
  balanceCache {.threadvar.}: Table[string, float64]

proc priorityTokenCmp(a, b: WalletTokenDto): int =
  for symbol in @["ETH", "SNT", "DAI", "STT"]:
    if a.symbol == symbol:
      return -1
    if b.symbol == symbol:
      return 1

  cmp(a.name, b.name)

proc hex2Balance*(input: string, decimals: int): string =
  var value = fromHex(Stuint[256], input)

  if decimals == 0:
    return fmt"{value}"

  var p = u256(10).pow(decimals)
  var i = value.div(p)
  var r = value.mod(p)
  var leading_zeros = "0".repeat(decimals - ($r).len)
  var d = fmt"{leading_zeros}{$r}"
  result = $i
  if(r > 0): result = fmt"{result}.{d}"

type AccountSaved* = ref object of Args
  account*: WalletAccountDto

type AccountDeleted* = ref object of Args
  address*: string

type CurrencyUpdated = ref object of Args

type NetwordkEnabledToggled = ref object of Args

type WalletAccountUpdated* = ref object of Args
  account*: WalletAccountDto

type DerivedAddressesArgs* = ref object of Args
  uniqueId*: string
  derivedAddresses*: seq[DerivedAddressDto]
  error*: string

type TokensPerAccountArgs* = ref object of Args
  accountsTokens*: OrderedTable[string, seq[WalletTokenDto]] # [wallet address, list of tokens]
  hasBalanceCache*: bool
  hasMarketValuesCache*: bool

type KeycardActivityArgs* = ref object of Args
  success*: bool
  oldKeycardUid*: string
  keycard*: KeycardDto

proc responseHasNoErrors(procName: string, response: RpcResponse[JsonNode]): bool =
  var errMsg = ""
  if not response.error.isNil:
    errMsg = "(" & $response.error.code & ") " & response.error.message
  elif response.result.kind == JObject and response.result.contains("error"):
    errMsg = response.result["error"].getStr
  if(errMsg.len == 0):
    return true
  error "error: ", procName=procName, errDesription = errMsg
  return false

include async_tasks
include  ../../common/json_utils

QtObject:
  type Service* = ref object of QObject
    closingApp: bool
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service
    accountsService: accounts_service.Service
    tokenService: token_service.Service
    networkService: network_service.Service
    walletAccounts: OrderedTable[string, WalletAccountDto]

  # Forward declaration
  proc buildAllTokens(self: Service, accounts: seq[string], store: bool)
  proc checkRecentHistory*(self: Service)
  proc startWallet(self: Service)
  proc handleWalletAccount(self: Service, account: WalletAccountDto)
  proc handleKeycardActions(self: Service, keycardActions: seq[KeycardActionDto])
  proc handleKeycardsState(self: Service, keycardsState: seq[KeycardDto])
  proc getAllKnownKeycards*(self: Service): seq[KeycardDto]
  proc removeMigratedAccountsForKeycard*(self: Service, keyUid: string, keycardUid: string, accountsToRemove: seq[string])

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingsService: settings_service.Service,
    accountsService: accounts_service.Service,
    tokenService: token_service.Service,
    networkService: network_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.accountsService = accountsService
    result.tokenService = tokenService
    result.networkService = networkService
    result.walletAccounts = initOrderedTable[string, WalletAccountDto]()

  proc getAccounts*(self: Service): seq[WalletAccountDto] =
    try:
      let response = status_go_accounts.getAccounts()
      return response.result.getElems().map(
          x => x.toWalletAccountDto()
        ).filter(a => not a.isChat)
    except Exception as e:
      error "error: ", procName="getAccounts", errName = e.name, errDesription = e.msg

  proc getWatchOnlyAccounts*(self: Service): seq[WalletAccountDto] =
    try:
      let response = status_go_accounts.getWatchOnlyAccounts()
      return response.result.getElems().map(x => x.toWalletAccountDto())
    except Exception as e:
      error "error: ", procName="getWatchOnlyAccounts", errName = e.name, errDesription = e.msg

  proc getKeypairs*(self: Service): seq[KeypairDto] =
    try:
      let response = status_go_accounts.getKeypairs()
      return response.result.getElems().map(x => x.toKeypairDto())
    except Exception as e:
      error "error: ", procName="getKeypairs", errName = e.name, errDesription = e.msg

  proc getKeypairByKeyUid*(self: Service, keyUid: string): KeypairDto =
    if keyUid.len == 0:
      return
    try:
      let response = status_go_accounts.getKeypairByKeyUid(keyUid)
      if not response.error.isNil:
        return
      return response.result.toKeypairDto()
    except Exception as e:
      info "no known keypair", keyUid=keyUid, procName="getKeypairByKeyUid", errName = e.name, errDesription = e.msg

  proc verifyKeystoreFileForAccount*(self: Service, account, password: string): bool =
    try:
      let hashedPassword = utils.hashPassword(password)
      let response = status_go_accounts.verifyKeystoreFileForAccount(account, hashedPassword)
      return response.result.getBool
    except Exception as e:
      error "error: ", procName="verifyKeystoreFileForAccount", errName = e.name, errDesription = e.msg
    return false

  proc setEnsName(self: Service, account: WalletAccountDto) =
    let chainId = self.networkService.getNetworkForEns().chainId
    try:
      let nameResponse = backend.getName(chainId, account.address)
      account.ens = nameResponse.result.getStr
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc setRelatedAccountsToAccount(self: Service, account: WalletAccountDto) =
    let keypair = self.getKeypairByKeyUid(account.keyUid)
    if keypair.isNil:
      return
    account.relatedAccounts = keypair.accounts

  proc setRelatedAccountsForAllAccounts(self: Service, keyUid: string) =
    for wAcc in self.walletAccounts.mvalues:
      if wAcc.keyUid == keyUid:
        self.setRelatedAccountsToAccount(wAcc)

  proc storeAccount(self: Service, account: WalletAccountDto, updateRelatedAccounts = true) =
    if updateRelatedAccounts:
      # updating related accounts for already added accounts
      self.setRelatedAccountsForAllAccounts(account.keyUid)
    # add new account to store
    self.walletAccounts[account.address] = account

  proc storeTokensForAccount*(self: Service, address: string, tokens: seq[WalletTokenDto], areBalancesCached: bool, areMarketValuesCached: bool) =
    if self.walletAccounts.hasKey(address):
      deepCopy(self.walletAccounts[address].tokens, tokens)
      self.walletAccounts[address].hasBalanceCache = areBalancesCached
      self.walletAccounts[address].hasMarketValuesCache = areMarketValuesCached

  proc allBalancesForAllTokensHaveError(tokens: seq[WalletTokenDto]): bool =
    for token in tokens:
      for chainId, balanceDto in token.balancesPerChain:
        if not balanceDto.hasError:
          return false
    return true

  proc anyTokenHasBalanceForAnyChain(tokens: seq[WalletTokenDto]): bool =
    for token in tokens:
      if len(token.balancesPerChain) > 0:
        return true
    return false

  proc allMarketValuesForAllTokensHaveError(tokens: seq[WalletTokenDto]): bool =
    for token in tokens:
      for currency, marketDto in token.marketValuesPerCurrency:
        if not marketDto.hasError:
          return false
    return true

  proc anyTokenHasMarketValuesForAnyChain(tokens: seq[WalletTokenDto]): bool =
    for token in tokens:
      if len(token.marketValuesPerCurrency) > 0:
        return true
    return false

  proc updateReceivedTokens*(self: Service, address: string, tokens: var seq[WalletTokenDto]) =
    if not self.walletAccounts.hasKey(address) or
      self.walletAccounts[address].tokens.len == 0:
        return

    let allBalancesForAllTokensHaveError = allBalancesForAllTokensHaveError(tokens)
    let allMarketValuesForAllTokensHaveError = allMarketValuesForAllTokensHaveError(tokens)

    for waToken in self.walletAccounts[address].tokens:
      for token in tokens.mitems:
        if waToken.name == token.name:
          if allBalancesForAllTokensHaveError:
            token.balancesPerChain = waToken.balancesPerChain
          if allMarketValuesForAllTokensHaveError:
            token.marketValuesPerCurrency = waToken.marketValuesPerCurrency

  proc walletAccountsContainsAddress*(self: Service, address: string): bool =
    return self.walletAccounts.hasKey(address)

  proc getAccountByAddress*(self: Service, address: string): WalletAccountDto =
    result = WalletAccountDto()
    if not self.walletAccountsContainsAddress(address):
      return
    result = self.walletAccounts[address]

  proc getAccountsByAddresses*(self: Service, addresses: seq[string]): seq[WalletAccountDto] =
    for address in addresses:
      result.add(self.getAccountByAddress(address))

  proc getTokensByAddresses*(self: Service, addresses: seq[string]): seq[WalletTokenDto] =
    var tokens = initTable[string, WalletTokenDto]()
    for address in addresses:
      let walletAccount = self.getAccountByAddress(address)
      for token in walletAccount.tokens:
        if not tokens.hasKey(token.symbol):
          let newToken = token.copyToken()
          tokens[token.symbol] = newToken
          continue

        for chainId, balanceDto in token.balancesPerChain:
          if not tokens[token.symbol].balancesPerChain.hasKey(chainId):
            tokens[token.symbol].balancesPerChain[chainId] = balanceDto
            continue

          tokens[token.symbol].balancesPerChain[chainId].balance += balanceDto.balance

    result = toSeq(tokens.values)
    result.sort(priorityTokenCmp)

  proc getWalletAccounts*(self: Service): seq[WalletAccountDto] =
    result = toSeq(self.walletAccounts.values)

  proc getAddresses*(self: Service): seq[string] =
    result = toSeq(self.walletAccounts.keys())

  proc init*(self: Service) =
    try:
      let accounts = self.getAccounts()
      for account in accounts:
        let account = account # TODO https://github.com/nim-lang/Nim/issues/16740
        self.setEnsName(account)
        self.setRelatedAccountsToAccount(account)
        self.storeAccount(account)

      self.buildAllTokens(self.getAddresses(), store = true)
      self.checkRecentHistory()
      self.startWallet()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)
      if receivedData.walletAccounts.len > 0:
        for acc in receivedData.walletAccounts:
          self.handleWalletAccount(acc)
      self.handleKeycardsState(receivedData.keycards)
      self.handleKeycardActions(receivedData.keycardActions)

    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-tick-reload":
          self.buildAllTokens(self.getAddresses(), store = true)
          self.checkRecentHistory()

    self.events.on(SIGNAL_CURRENCY_UPDATED) do(e:Args):
      self.buildAllTokens(self.getAddresses(), store = true)

  proc reloadAccountTokens*(self: Service) =
    self.buildAllTokens(self.getAddresses(), store = true)
    self.checkRecentHistory()

  proc getWalletAccount*(self: Service, accountIndex: int): WalletAccountDto =
    let accounts = self.getWalletAccounts()
    if accountIndex < 0 or accountIndex >= accounts.len:
      return
    return accounts[accountIndex]

  proc getIndex*(self: Service, address: string): int =
    let accounts = self.getWalletAccounts()
    for i in 0 ..< accounts.len:
      if cmpIgnoreCase(accounts[i].address, address) == 0:
        return i

  proc startWallet(self: Service) =
    if(not main_constants.WALLET_ENABLED):
      return

    discard backend.startWallet()

  proc checkRecentHistory*(self: Service) =
    if(not main_constants.WALLET_ENABLED):
      return

    try:
      let addresses = self.getWalletAccounts().map(a => a.address)
      let chainIds = self.networkService.getNetworks().map(a => a.chainId)
      status_go_transactions.checkRecentHistory(chainIds, addresses)
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return

  proc addNewAccountToLocalStoreAndNotify(self: Service) =
    let accounts = self.getAccounts()
    var newAccount: WalletAccountDto
    var found = false
    for account in accounts:
      let account = account # TODO https://github.com/nim-lang/Nim/issues/16740
      if not self.walletAccountsContainsAddress(account.address):
        found = true
        newAccount = account
        break

    if not found:
      info "no new accounts identified to be stored"
      return

    self.setEnsName(newAccount)
    self.setRelatedAccountsToAccount(newAccount)
    self.storeAccount(newAccount)

    self.buildAllTokens(@[newAccount.address], store = true)
    self.events.emit(SIGNAL_WALLET_ACCOUNT_SAVED, AccountSaved(account: newAccount))

  proc removeAccountFromLocalStoreAndNotify(self: Service, address: string) =
    if not self.walletAccountsContainsAddress(address):
      return
    let removedAcc = self.walletAccounts[address]
    self.walletAccounts.del(address)
    # updating related accounts for other accounts
    self.setRelatedAccountsForAllAccounts(removedAcc.keyUid)
    self.events.emit(SIGNAL_WALLET_ACCOUNT_DELETED, AccountDeleted(address: address))

  proc updateAccountFromLocalStoreAndNotify(self: Service, address, name, colorId, emoji: string) =
    if not self.walletAccountsContainsAddress(address):
      return
    var account = self.getAccountByAddress(address)
    account.name = name
    account.colorId = colorId
    account.emoji = emoji
    self.storeAccount(account, updateRelatedAccounts = false)
    self.events.emit(SIGNAL_WALLET_ACCOUNT_UPDATED, WalletAccountUpdated(account: account))

  ## if password is not provided local keystore file won't be created
  proc addWalletAccount*(self: Service, password: string, doPasswordHashing: bool, name, address, path, publicKey,
    keyUid, accountType, colorId, emoji: string): string =
    try:
      var response: RpcResponse[JsonNode]
      if password.len == 0:
        response = status_go_accounts.addAccountWithoutKeystoreFileCreation(name, address, path, publicKey, keyUid,
          accountType, colorId, emoji)
      else:
        var finalPassword = password
        if doPasswordHashing:
          finalPassword = utils.hashPassword(password)
        response = status_go_accounts.addAccount(finalPassword, name, address, path, publicKey, keyUid, accountType,
          colorId, emoji)
      if not response.error.isNil:
        error "status-go error", procName="addWalletAccount", errCode=response.error.code, errDesription=response.error.message
        return response.error.message
      self.addNewAccountToLocalStoreAndNotify()
      return ""
    except Exception as e:
      error "error: ", procName="addWalletAccount", errName=e.name, errDesription=e.msg
      return e.msg

  ## Mandatory fields for account: `address`, `keyUid`, `walletType`, `path`, `publicKey`, `name`, `emoji`, `colorId`
  proc addNewPrivateKeyKeypair*(self: Service, privateKey, password: string, doPasswordHashing: bool,
    keyUid, keypairName, rootWalletMasterKey: string, account: WalletAccountDto): string =
    if password.len == 0:
      error "for adding new private key account, password must be provided"
      return
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
      self.addNewAccountToLocalStoreAndNotify()
      return ""
    except Exception as e:
      error "error: ", procName="addNewPrivateKeyKeypair", errName=e.name, errDesription=e.msg
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
        self.addNewAccountToLocalStoreAndNotify()
      return ""
    except Exception as e:
      error "error: ", procName="addNewSeedPhraseKeypair", errName=e.name, errDesription=e.msg
      return e.msg

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

  proc getCurrency*(self: Service): string =
    return self.settingsService.getCurrency()

  proc updateCurrency*(self: Service, newCurrency: string) =
    discard self.settingsService.saveCurrency(newCurrency)

  proc setNetworksState*(self: Service, chainIds: seq[int], enabled: bool) =
    self.networkService.setNetworksState(chainIds, enabled)
    self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, NetwordkEnabledToggled())

  proc toggleTestNetworksEnabled*(self: Service) =
    discard self.settingsService.toggleTestNetworksEnabled()
    self.buildAllTokens(self.getAddresses(), store = true)
    self.tokenService.loadData()
    self.checkRecentHistory()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, NetwordkEnabledToggled())

  proc updateWalletAccount*(self: Service, address: string, accountName: string, colorId: string, emoji: string): bool =
    if not self.walletAccountsContainsAddress(address):
      error "account's address is not among known addresses: ", address=address
      return false
    try:
      var account = self.getAccountByAddress(address)
      let response = status_go_accounts.updateAccount(accountName, account.address, account.path, account.publicKey,
        account.keyUid, account.walletType, colorId, emoji, account.isWallet, account.isChat)
      if not response.error.isNil:
        error "status-go error", procName="updateWalletAccount", errCode=response.error.code, errDesription=response.error.message
        return false
      self.updateAccountFromLocalStoreAndNotify(address, accountName, colorId, emoji)
      return true
    except Exception as e:
      error "error: ", procName="updateWalletAccount", errName=e.name, errDesription=e.msg
    return false

  proc fetchDerivedAddresses*(self: Service, password: string, derivedFrom: string, paths: seq[string], hashPassword: bool)=
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

  proc updateAssetsLoadingState(self: Service, wAddress: string, loading: bool) =
    if not self.walletAccountsContainsAddress(wAddress):
      return
    self.walletAccounts[wAddress].assetsLoading = loading

  proc onAllTokensBuilt*(self: Service, response: string) {.slot.} =
    try:
      var visibleSymbols: seq[string]
      let chainIds = self.networkService.getNetworks().map(n => n.chainId)

      let responseObj = response.parseJson
      var storeResult: bool
      var resultObj: JsonNode
      discard responseObj.getProp("storeResult", storeResult)
      discard responseObj.getProp("result", resultObj)

      var data = TokensPerAccountArgs()
      data.accountsTokens = initOrderedTable[string, seq[WalletTokenDto]]()
      data.hasBalanceCache = false
      data.hasMarketValuesCache = false
      if resultObj.kind == JObject:
        for wAddress, tokensDetailsObj in resultObj:
          if tokensDetailsObj.kind == JArray:
            var tokens: seq[WalletTokenDto]
            tokens = map(tokensDetailsObj.getElems(), proc(x: JsonNode): WalletTokenDto = x.toWalletTokenDto())
            tokens.sort(priorityTokenCmp)
            self.updateReceivedTokens(wAddress, tokens)
            let hasBalanceCache = anyTokenHasBalanceForAnyChain(tokens)
            let hasMarketValuesCache = anyTokenHasMarketValuesForAnyChain(tokens)
            data.accountsTokens[wAddress] = @[]
            deepCopy(data.accountsTokens[wAddress], tokens)
            data.hasBalanceCache = data.hasBalanceCache or hasBalanceCache
            data.hasMarketValuesCache = data.hasMarketValuesCache or hasMarketValuesCache

            # set assetsLoading to false once the tokens are loaded
            self.updateAssetsLoadingState(wAddress, false)

            if storeResult:
              self.storeTokensForAccount(wAddress, tokens, hasBalanceCache, hasMarketValuesCache)
              self.tokenService.updateTokenPrices(tokens) # For efficiency. Will be removed when token info fetching gets moved to the tokenService
              # Gather symbol for visible tokens
              for token in tokens:
                if token.getVisibleForNetworkWithPositiveBalance(chainIds) and find(visibleSymbols, token.symbol) == -1:
                  visibleSymbols.add(token.symbol)
      self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, data)
      if visibleSymbols.len > 0:
        discard backend.updateVisibleTokens(visibleSymbols)
    except Exception as e:
      error "error: ", procName="onAllTokensBuilt", errName = e.name, errDesription = e.msg

  proc buildAllTokens(self: Service, accounts: seq[string], store: bool) =
    if not main_constants.WALLET_ENABLED or
      accounts.len == 0:
        return

    # set assetsLoading to true as the tokens are being loaded
    for waddress in accounts:
      self.updateAssetsLoadingState(waddress, true)

    let arg = BuildTokensTaskArg(
      tptr: cast[ByteAddress](prepareTokensTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAllTokensBuilt",
      accounts: accounts,
      storeResult: store
    )
    self.threadpool.start(arg)

  proc getCurrentCurrencyIfEmpty(self: Service, currency = ""): string =
    if currency != "":
      return currency
    else:
      return self.getCurrency()

  proc getNetworkCurrencyBalance*(self: Service, network: NetworkDto, currency: string = ""): float64 =
    let accounts = self.getWalletAccounts()
    for walletAccount in accounts:
      result += walletAccount.getCurrencyBalance(@[network.chainId], self.getCurrentCurrencyIfEmpty(currency))

  proc findTokenSymbolByAddress*(self: Service, address: string): string =
    return self.tokenService.findTokenSymbolByAddress(address)

  proc getOrFetchBalanceForAddressInPreferredCurrency*(self: Service, address: string): tuple[balance: float64, fetched: bool] =
    if self.walletAccountsContainsAddress(address):
      let chainIds = self.networkService.getNetworks().map(n => n.chainId)
      result.balance = self.getAccountByAddress(address).getCurrencyBalance(chainIds, self.getCurrentCurrencyIfEmpty())
      result.fetched = true
    else:
      self.buildAllTokens(@[address], store = false)
      result.balance = 0.0
      result.fetched = false

  proc getTotalCurrencyBalance*(self: Service, addresses: seq[string], currency: string = ""): float64 =
    let chainIds = self.networkService.getNetworks().filter(a => a.enabled).map(a => a.chainId)
    let accounts = self.getWalletAccounts().filter(w => addresses.contains(w.address))
    return accounts.map(a => a.getCurrencyBalance(chainIds, self.getCurrentCurrencyIfEmpty(currency))).foldl(a + b, 0.0)

  proc getTokenBalanceOnChain*(self: Service, address: string, chainId: int, symbol: string): float64 =
    let account = self.getAccountByAddress(address)
    for token in account.tokens:
      if token.symbol == symbol and token.balancesPerChain.hasKey(chainId):
        return token.balancesPerChain[chainId].balance

    return 0.0

  proc addKeycardOrAccountsAsync*(self: Service, keycard: KeycardDto, accountsComingFromKeycard: bool = false) =
    let arg = AddKeycardOrAddAccountsIfKeycardIsAddedTaskArg(
      tptr: cast[ByteAddress](addKeycardOrAddAccountsIfKeycardIsAddedTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onKeycardAdded",
      keycard: keycard,
      accountsComingFromKeycard: accountsComingFromKeycard
    )
    self.threadpool.start(arg)

  proc emitAddKeycardAddAccountsChange(self: Service, success: bool, keycard: KeycardDto) =
    let data = KeycardActivityArgs(
      success: success,
      keycard: keycard
    )
    self.events.emit(SIGNAL_NEW_KEYCARD_SET, data)

  proc onKeycardAdded*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      var keycard: KeycardDto
      var success = false
      discard responseObj.getProp("success", success)
      if success:
        var kpJson: JsonNode
        if responseObj.getProp("keycard", kpJson):
          keycard = kpJson.toKeycardDto()
      self.emitAddKeycardAddAccountsChange(success, keycard)
    except Exception as e:
      error "error handilng migrated keycard response", errDesription=e.msg
      self.emitAddKeycardAddAccountsChange(success = false, KeycardDto())

  proc addKeycardOrAccounts*(self: Service, keycard: KeycardDto, accountsComingFromKeycard: bool = false): bool =
    try:
      let response = backend.addKeycardOrAddAccountsIfKeycardIsAdded(
        keycard.keycardUid,
        keycard.keycardName,
        keycard.keyUid,
        keycard.accountsAddresses,
        accountsComingFromKeycard
        )
      result = responseHasNoErrors("addKeycardOrAccounts", response)
      if result:
        self.emitAddKeycardAddAccountsChange(success = true, keycard)
    except Exception as e:
      error "error: ", procName="addKeycardOrAccounts", errName = e.name, errDesription = e.msg

  proc removeMigratedAccountsForKeycard*(self: Service, keyUid: string, keycardUid: string, accountsToRemove: seq[string]) =
    let arg = RemoveMigratedAccountsForKeycardTaskArg(
      tptr: cast[ByteAddress](removeMigratedAccountsForKeycardTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onMigratedAccountsForKeycardRemoved",
      keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid, accountsAddresses: accountsToRemove)
    )
    self.threadpool.start(arg)

  proc emitKeycardRemovedAccountsChange(self: Service, success: bool, keyUid: string, keycardUid: string,
    removedAccounts: seq[string]) =
    let data = KeycardActivityArgs(
      success: success,
      keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid, accountsAddresses: removedAccounts)
    )
    self.events.emit(SIGNAL_KEYCARD_ACCOUNTS_REMOVED, data)

  proc onMigratedAccountsForKeycardRemoved*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      var keycard: KeycardDto
      var success = false
      discard responseObj.getProp("success", success)
      if success:
        var kpJson: JsonNode
        if responseObj.getProp("keycard", kpJson):
          keycard = kpJson.toKeycardDto()
      self.emitKeycardRemovedAccountsChange(success, keycard.keyUid, keycard.keycardUid, keycard.accountsAddresses)
    except Exception as e:
      error "error handilng migrated keycard response", errDesription=e.msg
      self.emitKeycardRemovedAccountsChange(success = false, keyUid = "", keycardUid = "", removedAccounts = @[])

  proc getAllKnownKeycards*(self: Service): seq[KeycardDto] =
    try:
      let response = backend.getAllKnownKeycards()
      if responseHasNoErrors("getAllKnownKeycards", response):
        return map(response.result.getElems(), proc(x: JsonNode): KeycardDto = toKeycardDto(x))
    except Exception as e:
      error "error: ", procName="getAllKnownKeycards", errName = e.name, errDesription = e.msg

  proc getKeycardWithKeycardUid*(self: Service, keycardUid: string): KeycardDto =
    let allKnownKeycards = self.getAllKnownKeycards()
    let keycardsWithKeycardUid = allKnownKeycards.filter(kp => kp.keycardUid == keycardUid)
    if keycardsWithKeycardUid.len == 0:
      return
    if keycardsWithKeycardUid.len > 1:
      error "there are more than one keycard with the same uid", keycardUid=keycardUid
      return
    return keycardsWithKeycardUid[0]

  proc getAllKnownKeycardsGroupedByKeyUid*(self: Service): seq[KeycardDto] =
    try:
      let response = backend.getAllKnownKeycardsGroupedByKeyUid()
      if responseHasNoErrors("getAllKnownKeycardsGroupedByKeyUid", response):
        return map(response.result.getElems(), proc(x: JsonNode): KeycardDto = toKeycardDto(x))
    except Exception as e:
      error "error: ", procName="getAllKnownKeycardsGroupedByKeyUid", errName = e.name, errDesription = e.msg

  proc getKeycardByKeyUid*(self: Service, keyUid: string): seq[KeycardDto] =
    try:
      let response = backend.getKeycardByKeyUid(keyUid)
      if responseHasNoErrors("getKeycardByKeyUid", response):
        return map(response.result.getElems(), proc(x: JsonNode): KeycardDto = toKeycardDto(x))
    except Exception as e:
      error "error: ", procName="getKeycardByKeyUid", errName = e.name, errDesription = e.msg

  proc isKeycardAccount*(self: Service, account: WalletAccountDto): bool =
    if account.isNil or
      account.keyUid.len == 0 or
      account.path.len == 0 or
      utils.isPathOutOfTheDefaultStatusDerivationTree(account.path):
        return false
    let keycards = self.getKeycardByKeyUid(account.keyUid)
    return keycards.len > 0

  proc emitKeycardNameChange(self: Service, keycardUid: string, name: string) =
    let data = KeycardActivityArgs(success: true, keycard: KeycardDto(keycardUid: keycardUid, keycardName: name))
    self.events.emit(SIGNAL_KEYCARD_NAME_CHANGED, data)

  proc updateKeycardName*(self: Service, keycardUid: string, name: string): bool =
    try:
      let response = backend.setKeycardName(keycardUid, name)
      result = responseHasNoErrors("updateKeycardName", response)
      if result:
        self.emitKeycardNameChange(keycardUid, name)
    except Exception as e:
      error "error: ", procName="updateKeycardName", errName = e.name, errDesription = e.msg

  proc emitKeycardLockedChange(self: Service, keyUid: string, keycardUid: string) =
    let data = KeycardActivityArgs(success: true, keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid))
    self.events.emit(SIGNAL_KEYCARD_LOCKED, data)

  proc setKeycardLocked*(self: Service, keyUid: string, keycardUid: string): bool =
    try:
      let response = backend.keycardLocked(keycardUid)
      result = responseHasNoErrors("setKeycardLocked", response)
      if result:
        self.emitKeycardLockedChange(keyUid, keycardUid)
    except Exception as e:
      error "error: ", procName="setKeycardLocked", errName = e.name, errDesription = e.msg

  proc emitKeycardUnlockedChange(self: Service, keyUid: string, keycardUid: string) =
    let data = KeycardActivityArgs(success: true, keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid))
    self.events.emit(SIGNAL_KEYCARD_UNLOCKED, data)

  proc setKeycardUnlocked*(self: Service, keyUid: string, keycardUid: string): bool =
    try:
      let response = backend.keycardUnlocked(keycardUid)
      result = responseHasNoErrors("setKeycardUnlocked", response)
      if result:
        self.emitKeycardUnlockedChange(keyUid, keycardUid)
    except Exception as e:
      error "error: ", procName="setKeycardUnlocked", errName = e.name, errDesription = e.msg

  proc emitUpdateKeycardUidChange(self: Service, oldKeycardUid: string, newKeycardUid: string) =
    let data = KeycardActivityArgs(success: true, oldKeycardUid: oldKeycardUid, keycard: KeycardDto(keycardUid: newKeycardUid))
    self.events.emit(SIGNAL_KEYCARD_UID_UPDATED, data)

  proc updateKeycardUid*(self: Service, oldKeycardUid: string, newKeycardUid: string): bool =
    try:
      let response = backend.updateKeycardUID(oldKeycardUid, newKeycardUid)
      result = responseHasNoErrors("updateKeycardUid", response)
      if result:
        self.emitUpdateKeycardUidChange(oldKeycardUid, newKeycardUid)
    except Exception as e:
      error "error: ", procName="updateKeycardUid", errName = e.name, errDesription = e.msg

  proc emitDeleteKeycardChange(self: Service, keycardUid: string) =
    let data = KeycardActivityArgs(success: true, keycard: KeycardDto(keycardUid: keycardUid))
    self.events.emit(SIGNAL_KEYCARD_DELETED, data)

  proc deleteKeycard*(self: Service, keycardUid: string): bool =
    try:
      let response = backend.deleteKeycard(keycardUid)
      result = responseHasNoErrors("deleteKeycard", response)
      if result:
        self.emitDeleteKeycardChange(keycardUid)
    except Exception as e:
      error "error: ", procName="deleteKeycard", errName = e.name, errDesription = e.msg
    return false

  proc handleWalletAccount(self: Service, account: WalletAccountDto) =
    if account.removed:
      self.removeAccountFromLocalStoreAndNotify(account.address)
    else:
      if self.walletAccountsContainsAddress(account.address):
        self.updateAccountFromLocalStoreAndNotify(account.address, account.name, account.colorId, account.emoji)
      else:
        self.addNewAccountToLocalStoreAndNotify()

  proc handleKeycardActions(self: Service, keycardActions: seq[KeycardActionDto]) =
    if keycardActions.len == 0:
      return
    for kcAction in keycardActions:
      if kcAction.action == KeycardActionKeycardAdded or
        kcAction.action == KeycardActionAccountsAdded:
          self.emitAddKeycardAddAccountsChange(success = true, kcAction.keycard)
      elif kcAction.action == KeycardActionKeycardDeleted:
        self.emitDeleteKeycardChange(kcAction.keycard.keycardUid)
      elif kcAction.action == KeycardActionAccountsRemoved:
        let keycard = self.getKeycardWithKeycardUid(kcAction.keycard.keycardUid)
        self.emitKeycardRemovedAccountsChange(success = true, keycard.keyUid, kcAction.keycard.keycardUid, kcAction.keycard.accountsAddresses)
      elif kcAction.action == KeycardActionLocked:
        let keycard = self.getKeycardWithKeycardUid(kcAction.keycard.keycardUid)
        self.emitKeycardLockedChange(keycard.keyUid, kcAction.keycard.keycardUid)
      elif kcAction.action == KeycardActionUnlocked:
        let keycard = self.getKeycardWithKeycardUid(kcAction.keycard.keycardUid)
        self.emitKeycardUnlockedChange(keycard.keyUid, kcAction.keycard.keycardUid)
      elif kcAction.action == KeycardActionUidUpdated:
        self.emitUpdateKeycardUidChange(kcAction.oldKeycardUid, kcAction.keycard.keycardUid)
      elif kcAction.action == KeycardActionNameChanged:
        self.emitKeycardNameChange(kcAction.keycard.keycardUid, kcAction.keycard.keycardName)
      else:
        error "unsupported action received", action=kcAction.action

  proc handleKeycardsState(self: Service, keycardsState: seq[KeycardDto]) =
    if keycardsState.len == 0:
      return
    let data = KeycardActivityArgs(success: true)
    self.events.emit(SIGNAL_KEYCARDS_SYNCHRONIZED, data)

  proc allAccountsTokenBalance*(self: Service, symbol: string): float64 =
    var totalTokenBalance = 0.0
    for walletAccount in self.getWalletAccounts:
      if walletAccount.walletType != WalletTypeWatch:
        for token in walletAccount.tokens:
          if token.symbol == symbol:
            totalTokenBalance += token.getTotalBalanceOfSupportedChains()

    return totalTokenBalance
