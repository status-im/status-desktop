import Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils
import web3/[ethtypes, conversions]

import ../settings/service_interface as settings_service
import ../accounts/service_interface as accounts_service
import ../token/service as token_service
import ../../common/account_constants

import ./service_interface, ./dto

import ../../../app/core/eventemitter
import ../../../backend/accounts as status_go_accounts
import ../../../backend/tokens as status_go_tokens
import ../../../backend/wallet as status_go_wallet
import ../../../backend/eth as status_go_eth

export service_interface

logScope:
  topics = "wallet-account-service"

const SIGNAL_WALLET_ACCOUNT_SAVED* = "walletAccount/accountSaved"
const SIGNAL_WALLET_ACCOUNT_DELETED* = "walletAccount/accountDeleted"
const SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED* = "walletAccount/currencyUpdated"
const SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED* = "walletAccount/tokenVisibilityUpdated"
const SIGNAL_WALLET_ACCOUNT_UPDATED* = "walletAccount/walletAccountUpdated"

var
  priceCache {.threadvar.}: Table[string, float64]
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


proc fetchPrice(crypto: string, fiat: string): float64 =
  let key = crypto & fiat
  if priceCache.hasKey(key):
    return priceCache[key]

  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext)
  try:
    let url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    let parsedResponse = parseJson(response.body)
    if (parsedResponse{"Response"} != nil and parsedResponse{"Response"}.getStr == "Error"):
      error "Error while getting price", message = parsedResponse["Message"].getStr
      return 0.0
    result = parsefloat($parseJson(response.body)[fiat.toUpper])
    priceCache[key] = result
  except Exception as e:
    error "Error getting price", message = e.msg
    result = 0.0
  finally:
    client.close()

proc fetchAccounts(): seq[WalletAccountDto] =
  let response = status_go_accounts.getAccounts()
  return response.result.getElems().map(
    x => x.toWalletAccountDto()
  ).filter(a => not a.isChat)

proc fetchEthBalance(accountAddress: string): float64 =
  let key = "0x0" & accountAddress
  if balanceCache.hasKey(key):
    return balanceCache[key]

  let ethBalanceResponse = status_go_eth.getEthBalance(accountAddress)
  result = parsefloat(hex2Balance(ethBalanceResponse.result.getStr, 18))
  balanceCache[key] = result


type AccountSaved = ref object of Args
  account: WalletAccountDto

type AccountDeleted = ref object of Args
  account: WalletAccountDto

type CurrencyUpdated = ref object of Args

type TokenVisibilityToggled = ref object of Args

type WalletAccountUpdated = ref object of Args
  account: WalletAccountDto

type
  Service* = ref object of service_interface.ServiceInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface
    tokenService: token_service.Service
    accounts: OrderedTable[string, WalletAccountDto]

method delete*(self: Service) =
  discard

proc newService*(
  events: EventEmitter, settingsService: settings_service.ServiceInterface,
  accountsService: accounts_service.ServiceInterface,
  tokenService: token_service.Service):
  Service =
  result = Service()
  result.events = events
  result.settingsService = settingsService
  result.accountsService = accountsService
  result.tokenService = tokenService
  result.accounts = initOrderedTable[string, WalletAccountDto]()

method getVisibleTokens(self: Service): seq[TokenDto] =
  return self.tokenService.getTokens().filter(t => t.isVisible)

method buildTokens(
  self: Service,
  account: WalletAccountDto,
  prices: Table[string, float64],
  balances: JsonNode
): seq[WalletTokenDto] =
  let balance = fetchEthBalance(account.address)
  result = @[WalletTokenDto(
    name:"Ethereum",
    address: "0x0000000000000000000000000000000000000000",
    symbol: "ETH",
    decimals: 18,
    hasIcon: true,
    color: "blue",
    isCustom: false,
    balance: balance,
    currencyBalance: balance * prices["ETH"]
  )]

  for token in self.getVisibleTokens():
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

method getPrice*(self: Service, crypto: string, fiat: string): float64 =
  return fetchPrice(crypto, fiat)

method fetchPrices(self: Service): Table[string, float64] =
  let currency = self.settingsService.getCurrency()
  var prices = {"ETH": fetchPrice("ETH", currency)}.toTable
  for token in self.getVisibleTokens():
    prices[token.symbol] = fetchPrice(token.symbol, currency)

  return prices

method fetchBalances(self: Service, accounts: seq[string]): JsonNode =
  let chainId = self.settingsService.getCurrentNetworkId()
  let tokens = self.getVisibleTokens().map(t => t.addressAsString())
  return status_go_tokens.getBalances(chainId, accounts, tokens).result

method refreshBalances(self: Service) =
  let prices = self.fetchPrices()
  let accounts = toSeq(self.accounts.keys)
  let balances = self.fetchBalances(accounts)

  for account in toSeq(self.accounts.values):
    account.tokens = self.buildTokens(account, prices, balances{account.address})

method init*(self: Service) =
  try:
    let accounts = fetchAccounts()

    for account in accounts:
      self.accounts[account.address] = account

    self.refreshBalances()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAccountByAddress*(self: Service, address: string): WalletAccountDto =
  return self.accounts[address]

method getWalletAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values)

method getWalletAccount*(self: Service, accountIndex: int): WalletAccountDto =
  if(accountIndex < 0 or accountIndex >= self.getWalletAccounts().len):
    return
  return self.getWalletAccounts()[accountIndex]

method getCurrencyBalance*(self: Service): float64 =
  return self.getWalletAccounts().map(a => a.getCurrencyBalance()).foldl(a + b, 0.0)

method addNewAccountToLocalStore(self: Service) =
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

method generateNewAccount*(self: Service, password: string, accountName: string, color: string): string =
  try:
    discard status_go_wallet.generateAccount(
      password,
      accountName,
      color)
  except Exception as e:
    return fmt"Error generating new account: {e.msg}"

  self.addNewAccountToLocalStore()

method addAccountsFromPrivateKey*(self: Service, privateKey: string, password: string, accountName: string, color: string): string =
  try:
    discard status_go_wallet.addAccountWithPrivateKey(
      privateKey,
      password,
      accountName,
      color,
    )
  except Exception as e:
    return fmt"Error adding account with private key: {e.msg}"

  self.addNewAccountToLocalStore()

method addAccountsFromSeed*(self: Service, mnemonic: string, password: string, accountName: string, color: string): string =
  try:
    discard status_go_wallet.addAccountWithMnemonic(
      mnemonic,
      password,
      accountName,
      color,
    )
  except Exception as e:
    return fmt"Error adding account with mnemonic: {e.msg}"

  self.addNewAccountToLocalStore()

method addWatchOnlyAccount*(self: Service, address: string, accountName: string, color: string): string =
  try:
    discard status_go_wallet.addAccountWatch(
      address,
      accountName,
      color,
    )
  except Exception as e:
    return fmt"Error adding account with mnemonic: {e.msg}"

  self.addNewAccountToLocalStore()

method deleteAccount*(self: Service, address: string) =
  discard status_go_accounts.deleteAccount(address)
  let accountDeleted = self.accounts[address]
  self.accounts.del(address)

  self.events.emit(SIGNAL_WALLET_ACCOUNT_DELETED, AccountDeleted(account: accountDeleted))

method updateCurrency*(self: Service, newCurrency: string) =
  discard self.settingsService.saveCurrency(newCurrency)
  self.refreshBalances()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_CURRENCY_UPDATED, CurrencyUpdated())

method toggleTokenVisible*(self: Service, chainId: int, symbol: string) =
  self.tokenService.toggleVisible(chainId, symbol)
  self.refreshBalances()
  self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKEN_VISIBILITY_UPDATED, TokenVisibilityToggled())

method updateWalletAccount*(self: Service, address: string, accountName: string, color: string) =
  let account = self.accounts[address]
  status_go_accounts.updateAccount(
    accountName,
    account.address,
    account.publicKey,
    account.walletType,
    color
  )
  account.name = accountName
  account.color = color

  self.events.emit(SIGNAL_WALLET_ACCOUNT_UPDATED, WalletAccountUpdated(account: account))
