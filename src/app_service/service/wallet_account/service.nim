import NimQml, Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils, os
import web3/[ethtypes, conversions]

import ../settings/service as settings_service
import ../accounts/service as accounts_service
import ../token/service as token_service
import ../network/service as network_service
import ../../common/account_constants
import ../../../app/global/global_singleton

import dto
import derived_address

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../backend/accounts as status_go_accounts
import ../../../backend/backend as backend
import ../../../backend/eth as status_go_eth
import ../../../backend/cache

export dto
export derived_address

logScope:
  topics = "wallet-account-service"

const SIGNAL_WALLET_ACCOUNT_SAVED* = "walletAccount/accountSaved"
const SIGNAL_WALLET_ACCOUNT_DELETED* = "walletAccount/accountDeleted"
const SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED* = "walletAccount/currencyUpdated"
const SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED* = "walletAccount/tokenVisibilityUpdated"
const SIGNAL_WALLET_ACCOUNT_UPDATED* = "walletAccount/walletAccountUpdated"
const SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED* = "walletAccount/networkEnabledUpdated"
const SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESS_READY* = "walletAccount/derivedAddressesReady"
const SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT* = "walletAccount/tokensRebuilt"

var
  balanceCache {.threadvar.}: Table[string, float64]

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

proc fetchAccounts(): seq[WalletAccountDto] =
  let response = status_go_accounts.getAccounts()
  return response.result.getElems().map(
    x => x.toWalletAccountDto()
  ).filter(a => not a.isChat)

type AccountSaved = ref object of Args
  account: WalletAccountDto

type AccountDeleted* = ref object of Args
  account*: WalletAccountDto

type CurrencyUpdated = ref object of Args

type TokenVisibilityToggled = ref object of Args

type NetwordkEnabledToggled = ref object of Args

type WalletAccountUpdated = ref object of Args
  account: WalletAccountDto

type DerivedAddressesArgs* = ref object of Args
  derivedAddresses*: seq[DerivedAddressDto]
  error*: string

type TokensPerAccountArgs* = ref object of Args
  accountsTokens*: OrderedTable[string, seq[WalletTokenDto]] # [wallet address, list of tokens]

const CheckBalanceIntervalInMilliseconds = 15 * 60 * 1000 # 15 mins

include async_tasks
include  ../../common/json_utils

QtObject:
  type Service* = ref object of QObject
    closingApp: bool
    ignoreTimeInitiatedTokensBuild: bool
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service
    accountsService: accounts_service.Service
    tokenService: token_service.Service
    networkService: network_service.Service
    walletAccounts: OrderedTable[string, WalletAccountDto]

    priceCache: TimedCache

  # Forward declaration
  proc buildAllTokens(self: Service, calledFromTimerOrInit = false)

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
    result.ignoreTimeInitiatedTokensBuild = false
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.accountsService = accountsService
    result.tokenService = tokenService
    result.networkService = networkService
    result.walletAccounts = initOrderedTable[string, WalletAccountDto]()
    result.priceCache = newTimedCache()

  proc getPrice*(self: Service, crypto: string, fiat: string): float64 =
    let cacheKey = crypto & fiat
    if self.priceCache.isCached(cacheKey):
      return parseFloat(self.priceCache.get(cacheKey))
    var prices = initTable[string, float]()

    try:
      let response = backend.fetchPrices(@[crypto], fiat)
      for (symbol, value) in response.result.pairs:
        prices[symbol] = value.getFloat
        self.priceCache.set(cacheKey, $value.getFloat)

      return prices[crypto]
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return 0.0

  proc init*(self: Service) =
    signalConnect(singletonInstance.localAccountSensitiveSettings, "isWalletEnabledChanged()", self, "onIsWalletEnabledChanged()", 2)
    
    try:
      let accounts = fetchAccounts()
      for account in accounts:
        self.walletAccounts[account.address] = account

      self.buildAllTokens(true)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getAccountByAddress*(self: Service, address: string): WalletAccountDto =
    if not self.walletAccounts.hasKey(address):
      return
    return self.walletAccounts[address]

  proc getWalletAccounts*(self: Service): seq[WalletAccountDto] =
    return toSeq(self.walletAccounts.values)

  proc getWalletAccount*(self: Service, accountIndex: int): WalletAccountDto =
    if(accountIndex < 0 or accountIndex >= self.getWalletAccounts().len):
      return
    return self.getWalletAccounts()[accountIndex]

  proc getIndex*(self: Service, address: string): int =
    let accounts = self.getWalletAccounts()
    for i in 0..accounts.len:
      if(accounts[i].address == address):
        return i

  proc getCurrencyBalance*(self: Service): float64 =
    return self.getWalletAccounts().map(a => a.getCurrencyBalance()).foldl(a + b, 0.0)

  proc addNewAccountToLocalStore(self: Service) =
    let accounts = fetchAccounts()
    var newAccount = accounts[0]
    for account in accounts:
      if not self.walletAccounts.haskey(account.address):
        newAccount = account
        break
    self.walletAccounts[newAccount.address] = newAccount
    self.buildAllTokens()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_SAVED, AccountSaved(account: newAccount))

  proc generateNewAccount*(self: Service, password: string, accountName: string, color: string, emoji: string, path: string, derivedFrom: string): string =
    try:
      discard backend.generateAccountWithDerivedPath(
        hashPassword(password),
        accountName,
        color,
        emoji,
        path,
        derivedFrom)
    except Exception as e:
      return fmt"Error generating new account: {e.msg}"

    self.addNewAccountToLocalStore()

  proc addAccountsFromPrivateKey*(self: Service, privateKey: string, password: string, accountName: string, color: string, emoji: string): string =
    try:
      discard backend.addAccountWithPrivateKey(
        privateKey,
        hashPassword(password),
        accountName,
        color,
        emoji)
    except Exception as e:
      return fmt"Error adding account with private key: {e.msg}"

    self.addNewAccountToLocalStore()

  proc addAccountsFromSeed*(self: Service, mnemonic: string, password: string, accountName: string, color: string, emoji: string, path: string): string =
    try:
      discard backend.addAccountWithMnemonicAndPath(
        mnemonic,
        hashPassword(password),
        accountName,
        color,
        emoji,
        path
      )
    except Exception as e:
      return fmt"Error adding account with mnemonic: {e.msg}"

    self.addNewAccountToLocalStore()

  proc addWatchOnlyAccount*(self: Service, address: string, accountName: string, color: string, emoji: string): string =
    try:
      discard backend.addAccountWatch(
        address,
        accountName,
        color,
        emoji
      )
    except Exception as e:
      return fmt"Error adding account with mnemonic: {e.msg}"

    self.addNewAccountToLocalStore()

  proc deleteAccount*(self: Service, address: string) =
    discard status_go_accounts.deleteAccount(address)
    let accountDeleted = self.walletAccounts[address]
    self.walletAccounts.del(address)

    self.events.emit(SIGNAL_WALLET_ACCOUNT_DELETED, AccountDeleted(account: accountDeleted))

  proc updateCurrency*(self: Service, newCurrency: string) =
    discard self.settingsService.saveCurrency(newCurrency)
    self.buildAllTokens()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED, CurrencyUpdated())

  proc toggleTokenVisible*(self: Service, chainId: int, address: string) =
    self.tokenService.toggleVisible(chainId, address)
    self.buildAllTokens()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED, TokenVisibilityToggled())

  proc toggleNetworkEnabled*(self: Service, chainId: int) =
    self.networkService.toggleNetwork(chainId)
    self.tokenService.init()
    self.buildAllTokens()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, NetwordkEnabledToggled())

  method toggleTestNetworksEnabled*(self: Service) =
    discard self.settingsService.toggleTestNetworksEnabled()
    self.tokenService.init()
    self.buildAllTokens()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, NetwordkEnabledToggled())

  proc updateWalletAccount*(self: Service, address: string, accountName: string, color: string, emoji: string) =
    let account = self.walletAccounts[address]
    status_go_accounts.updateAccount(
      accountName,
      account.address,
      account.publicKey,
      account.walletType,
      color,
      emoji
    )
    account.name = accountName
    account.color = color
    account.emoji = emoji

    self.events.emit(SIGNAL_WALLET_ACCOUNT_UPDATED, WalletAccountUpdated(account: account))

  proc getDerivedAddressList*(self: Service, password: string, derivedFrom: string, path: string, pageSize: int, pageNumber: int)=
    let arg = GetDerivedAddressesTaskArg(
      password: hashPassword(password),
      derivedFrom: derivedFrom,
      path: path,
      pageSize: pageSize,
      pageNumber: pageNumber,
      tptr: cast[ByteAddress](getDerivedAddressesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setDerivedAddresses",
    )
    self.threadpool.start(arg)

  proc getDerivedAddressListForMnemonic*(self: Service, mnemonic: string, path: string, pageSize: int, pageNumber: int) =
    let arg = GetDerivedAddressesForMnemonicTaskArg(
      mnemonic: mnemonic,
      path: path,
      pageSize: pageSize,
      pageNumber: pageNumber,
      tptr: cast[ByteAddress](getDerivedAddressesForMnemonicTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setDerivedAddresses",
    )
    self.threadpool.start(arg)

  proc getDerivedAddressForPrivateKey*(self: Service, privateKey: string) =
    let arg = GetDerivedAddressForPrivateKeyTaskArg(
      privateKey: privateKey,
      tptr: cast[ByteAddress](getDerivedAddressForPrivateKeyTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setDerivedAddresses",
    )
    self.threadpool.start(arg)

  proc setDerivedAddresses*(self: Service, derivedAddressesJson: string) {.slot.} =
    let response = parseJson(derivedAddressesJson)
    var derivedAddress: seq[DerivedAddressDto] = @[]
    derivedAddress = response["derivedAddresses"].getElems().map(x => x.toDerivedAddressDto())
    let error = response["error"].getStr()

    # emit event
    self.events.emit(SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESS_READY, DerivedAddressesArgs(
      derivedAddresses: derivedAddress,
      error: error
    ))

  proc onStartBuildingTokensTimer*(self: Service, response: string) {.slot.} =
    if self.ignoreTimeInitiatedTokensBuild:
      self.ignoreTimeInitiatedTokensBuild = false
      return

    self.buildAllTokens(true)

  proc startBuildingTokensTimer(self: Service) =
    if(self.closingApp):
      return

    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onStartBuildingTokensTimer",
      timeoutInMilliseconds: CheckBalanceIntervalInMilliseconds
    )
    self.threadpool.start(arg)

  proc onAllTokensBuilt*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "prepared tokens are not a json object"
      return

    var data = TokensPerAccountArgs()
    let walletAddresses = toSeq(self.walletAccounts.keys)
    for wAddress in walletAddresses:
      var tokensArr: JsonNode
      var tokens: seq[WalletTokenDto]
      if(responseObj.getProp(wAddress, tokensArr)):
        tokens = map(tokensArr.getElems(), proc(x: JsonNode): WalletTokenDto = x.toWalletTokenDto())
      self.walletAccounts[wAddress].tokens = tokens
      data.accountsTokens[wAddress] = tokens

    self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, data)

    # run timer again...
    self.startBuildingTokensTimer()

  proc buildAllTokens(self: Service, calledFromTimerOrInit = false) =
    if(self.closingApp or not singletonInstance.localAccountSensitiveSettings.getIsWalletEnabled()):
      return

    # Since we don't have a way to re-run TimerTaskArg (to stop it and run again), we introduced some flags which will
    # just ignore buildAllTokens in case that proc is called by some action in the time window between two successive calls
    # initiated by TimerTaskArg.
    if not calledFromTimerOrInit:
      self.ignoreTimeInitiatedTokensBuild = true

    let walletAddresses = toSeq(self.walletAccounts.keys)

    let arg = BuildTokensTaskArg(
      tptr: cast[ByteAddress](prepareTokensTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAllTokensBuilt",
      walletAddresses: walletAddresses,
      currency: self.settingsService.getCurrency(),
      networks: self.networkService.getEnabledNetworks()
    )
    self.threadpool.start(arg)

  proc onIsWalletEnabledChanged*(self: Service) {.slot.} =
    self.buildAllTokens()