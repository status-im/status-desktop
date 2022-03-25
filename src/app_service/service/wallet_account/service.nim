import Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils
import web3/[ethtypes, conversions]

import ../settings/service as settings_service
import ../accounts/service as accounts_service
import ../token/service as token_service
import ../network/service as network_service
import ../../common/account_constants

import dto

import ../../../app/core/eventemitter
import ../../../backend/accounts as status_go_accounts
import ../../../backend/backend as backend
import ../../../backend/eth as status_go_eth
import ../../../backend/cache

export dto

logScope:
  topics = "wallet-account-service"

const SIGNAL_WALLET_ACCOUNT_SAVED* = "walletAccount/accountSaved"
const SIGNAL_WALLET_ACCOUNT_DELETED* = "walletAccount/accountDeleted"
const SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED* = "walletAccount/currencyUpdated"
const SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED* = "walletAccount/tokenVisibilityUpdated"
const SIGNAL_WALLET_ACCOUNT_UPDATED* = "walletAccount/walletAccountUpdated"
const SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED* = "walletAccount/networkEnabledUpdated"

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

proc fetchNativeChainBalance(network: NetworkDto, accountAddress: string): float64 =
  let key = "0x0" & accountAddress & $network.chainId
  if balanceCache.hasKey(key):
    return balanceCache[key]

  try:
    let nativeBalanceResponse = status_go_eth.getNativeChainBalance(network.chainId, accountAddress)
    result = parsefloat(hex2Balance(nativeBalanceResponse.result.getStr, network.nativeCurrencyDecimals))
    balanceCache[key] = result
  except Exception as e:
    error "Error getting balance", message = e.msg
    result = 0.0

type AccountSaved = ref object of Args
  account: WalletAccountDto

type AccountDeleted* = ref object of Args
  account*: WalletAccountDto

type CurrencyUpdated = ref object of Args

type TokenVisibilityToggled = ref object of Args

type NetwordkEnabledToggled = ref object of Args

type WalletAccountUpdated = ref object of Args
  account: WalletAccountDto

type
  Service* = ref object of RootObj
    events: EventEmitter
    settingsService: settings_service.Service
    accountsService: accounts_service.Service
    tokenService: token_service.Service
    networkService: network_service.Service
    accounts: OrderedTable[string, WalletAccountDto]

    priceCache: TimedCache


proc delete*(self: Service) =
  discard

proc newService*(
  events: EventEmitter, 
  settingsService: settings_service.Service,
  accountsService: accounts_service.Service,
  tokenService: token_service.Service,
  networkService: network_service.Service,
): Service =
  result = Service()
  result.events = events
  result.settingsService = settingsService
  result.accountsService = accountsService
  result.tokenService = tokenService
  result.networkService = networkService
  result.accounts = initOrderedTable[string, WalletAccountDto]()
  result.priceCache = newTimedCache()

proc buildTokens(
  self: Service,
  account: WalletAccountDto,
  prices: Table[string, float],
  balances: JsonNode
): seq[WalletTokenDto] =
  for network in self.networkService.getEnabledNetworks():
    let balance = fetchNativeChainBalance(network, account.address)
    result.add(WalletTokenDto(
      name: network.chainName,
      address: "0x0000000000000000000000000000000000000000",
      symbol: network.nativeCurrencySymbol,
      decimals: network.nativeCurrencyDecimals,
      hasIcon: true,
      color: "blue",
      isCustom: false,
      balance: balance,
      currencyBalance: balance * prices[network.nativeCurrencySymbol]
    ))

  for token in self.tokenService.getVisibleTokens():
    let balance = parsefloat(hex2Balance(balances{token.addressAsString()}.getStr, token.decimals))
    result.add(
      WalletTokenDto(
        name: token.name,
        address: $token.address,
        symbol: token.symbol,
        decimals: token.decimals,
        hasIcon: token.hasIcon,
        color: token.color,
        isCustom: token.isCustom,
        balance: balance,
        currencyBalance: balance * prices[token.symbol]
      )
    )

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
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription

  return prices[crypto]

proc fetchPrices(self: Service): Table[string, float] =
  let currency = self.settingsService.getCurrency()

  var symbols: seq[string] = @[]

  for network in self.networkService.getEnabledNetworks():
    symbols.add(network.nativeCurrencySymbol)

  for token in self.tokenService.getVisibleTokens():
    symbols.add(token.symbol)

  var prices = initTable[string, float]()
  try:
    let response = backend.fetchPrices(symbols, currency)
    for (symbol, value) in response.result.pairs:
      prices[symbol] = value.getFloat

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
  
  return prices

proc fetchBalances(self: Service, accounts: seq[string]): JsonNode =
  let visibleTokens = self.tokenService.getVisibleTokens()
  let tokens = visibleTokens.map(t => t.addressAsString())
  let chainIds = visibleTokens.map(t => t.chainId)
  return backend.getTokensBalancesForChainIDs(chainIds, accounts, tokens).result

proc refreshBalances(self: Service) =
  let prices = self.fetchPrices()
  let accounts = toSeq(self.accounts.keys)
  let balances = self.fetchBalances(accounts)

  for account in toSeq(self.accounts.values):
    account.tokens = self.buildTokens(account, prices, balances{account.address})

proc init*(self: Service) =
  try:
    let accounts = fetchAccounts()

    for account in accounts:
      self.accounts[account.address] = account

    self.refreshBalances()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc getAccountByAddress*(self: Service, address: string): WalletAccountDto =
  return self.accounts[address]

proc getWalletAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values)

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
  let prices = self.fetchPrices()

  var newAccount = accounts[0]
  for account in accounts:
    if not self.accounts.haskey(account.address):
      newAccount = account
      break

  let balances = self.fetchBalances(@[newAccount.address])
  newAccount.tokens = self.buildTokens(newAccount, prices, balances{newAccount.address})
  self.accounts[newAccount.address] = newAccount
  self.events.emit(SIGNAL_WALLET_ACCOUNT_SAVED, AccountSaved(account: newAccount))

proc generateNewAccount*(self: Service, password: string, accountName: string, color: string, emoji: string): string =
  try:
    discard backend.generateAccount(
      hashPassword(password),
      accountName,
      color,
      emoji)
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
      emoji
    )
  except Exception as e:
    return fmt"Error adding account with private key: {e.msg}"

  self.addNewAccountToLocalStore()

proc addAccountsFromSeed*(self: Service, mnemonic: string, password: string, accountName: string, color: string, emoji: string): string =
  try:
    discard backend.addAccountWithMnemonic(
      mnemonic,
      hashPassword(password),
      accountName,
      color,
      emoji
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
  let accountDeleted = self.accounts[address]
  self.accounts.del(address)

  self.events.emit(SIGNAL_WALLET_ACCOUNT_DELETED, AccountDeleted(account: accountDeleted))

proc updateCurrency*(self: Service, newCurrency: string) =
  discard self.settingsService.saveCurrency(newCurrency)
  self.refreshBalances()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED, CurrencyUpdated())

proc toggleTokenVisible*(self: Service, chainId: int, symbol: string) =
  self.tokenService.toggleVisible(chainId, symbol)
  self.refreshBalances()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED, TokenVisibilityToggled())

proc toggleNetworkEnabled*(self: Service, chainId: int) = 
  self.networkService.toggleNetwork(chainId)
  self.tokenService.init()
  self.refreshBalances()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED, NetwordkEnabledToggled())

proc updateWalletAccount*(self: Service, address: string, accountName: string, color: string, emoji: string) =
  let account = self.accounts[address]
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
