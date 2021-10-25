import Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils
import web3/[ethtypes, conversions]
import eventemitter

import ../setting/service as setting_service
import ../token/service as token_service
import ../../common/account_constants
import ../../../constants

import ./service_interface, ./dto
import status/statusgo_backend_new/accounts as status_go_accounts
import status/statusgo_backend_new/eth as status_go_eth

export service_interface

logScope:
  topics = "wallet-account-service"

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


proc fetchPrice(crypto: string, fiat: string): string =
  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext)
  try:
    let url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    result = $parseJson(response.body)[fiat.toUpper]
  except Exception as e:
    error "Error getting price", message = e.msg
    result = "0.0"
  finally:
    client.close()

proc fetchAccounts(): seq[WalletAccountDto] =
  let response = status_go_accounts.getAccounts()
  return response.result.getElems().map(
    x => x.toWalletAccountDto()
  ).filter(a => not a.isChat)

type AccountSaved = ref object of Args
  account: WalletAccountDto

type AccountDeleted = ref object of Args
  account: WalletAccountDto

type CurrencyUpdated = ref object of Args

type WalletAccountUpdated = ref object of Args
  account: WalletAccountDto

type
  Service* = ref object of service_interface.ServiceInterface
    events: EventEmitter
    settingService: setting_service.Service
    tokenService: token_service.Service
    accounts: Table[string, WalletAccountDto]

method delete*(self: Service) =
  discard

proc newService*(
  events: EventEmitter, settingService: setting_service.Service, tokenService: token_service.Service
): Service =
  result = Service()
  result.events = events
  result.settingService = settingService
  result.tokenService = tokenService
  result.accounts = initTable[string, WalletAccountDto]()

method getVisibleTokens(self: Service): seq[TokenDto] =
  return self.tokenService.getTokens().filter(t => t.isVisible)

method buildTokens(
  self: Service,
  account: WalletAccountDto,
  prices: Table[string, float64]
): seq[WalletTokenDto] =
  let ethBalanceResponse = status_go_eth.getEthBalance(account.address)
  let balance = parsefloat(hex2Balance(ethBalanceResponse.result.getStr, 18))
  result = @[WalletTokenDto(
    name:"Ethereum",
    address: account.address,
    symbol: "ETH",
    decimals: 18,
    hasIcon: true,
    color: "blue",
    isCustom: false,
    balance: balance,
    currencyBalance: balance * prices["ETH"]
  )]

  for token in self.getVisibleTokens():
    let tokenBalanceResponse = status_go_eth.getTokenBalance($token.address, account.address)
    let balance = parsefloat(hex2Balance(tokenBalanceResponse.result.getStr, token.decimals))
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

method fetchPrices(self: Service): Table[string, float64] =
  let currency = self.settingService.getSetting().currency
  var prices = {"ETH": parsefloat(fetchPrice("ETH", currency))}.toTable
  for token in self.getVisibleTokens():
    prices[token.symbol] = parsefloat(fetchPrice(token.symbol, currency))

  return prices

method init*(self: Service) =
  try:
    let accounts = fetchAccounts()
    let prices = self.fetchPrices()

    for account in accounts:
      account.tokens = self.buildTokens(account, prices)
      self.accounts[account.address] = account

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAccountByAddress*(self: Service, address: string): WalletAccountDto =
  return self.accounts[address]

method getWalletAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values)

method getWalletAccount*(self: Service, accountIndex: int): WalletAccountDto =
  return self.getWalletAccounts()[accountIndex]

method getCurrencyBalance*(self: Service): float64 =
  return self.getWalletAccounts().map(a => a.getCurrencyBalance()).foldl(a + b, 0.0)

method getDefaultAccount(self: Service): string =
  return status_go_eth.getAccounts().result[0].getStr

method saveAccount(
  self: Service,
  address: string,
  name: string,
  password: string,
  color: string,
  accountType: string,
  isADerivedAccount = true,
  walletIndex: int = 0,
  id: string = "",
  publicKey: string = "",
) =
  status_go_accounts.saveAccount(
    address,
    name,
    password,
    color,
    accountType,
    isADerivedAccount = true,
    walletIndex,
    id,
    publicKey,
  )
  # LOAD Account and build token
  let accounts = fetchAccounts()
  let prices = self.fetchPrices()

  var newAccount = accounts[0]
  for account in accounts:
    if account.address == address:
      newAccount = account
      break

  newAccount.tokens = self.buildTokens(newAccount, prices)
  self.accounts[newAccount.address] = newAccount
  self.events.emit("walletAccount/accountSaved", AccountSaved(account: newAccount))

method generateNewAccount*(self: Service, password: string, accountName: string, color: string) =
  let
    setting = self.settingService.getSetting()
    walletRootAddress = setting.walletRootAddress
    walletIndex = setting.latestDerivedPath + 1

  let accountResponse = status_go_accounts.loadAccount(walletRootAddress, password)
  let accountId = accountResponse.result{"id"}.getStr
  let path = "m/" & $walletIndex
  let deriveResponse = status_go_accounts.deriveAccounts(accountId, @[path])
  self.saveAccount(
    deriveResponse.result[path]{"address"}.getStr,
    accountName,
    password,
    color,
    status_go_accounts.GENERATED,
    true,
    walletIndex,
    accountId,
    deriveResponse.result[path]{"publicKey"}.getStr
  )

  discard self.settingService.saveSetting("latest-derived-path", walletIndex)

method addAccountsFromPrivateKey*(self: Service, privateKey: string, password: string, accountName: string, color: string) =
  let
    accountResponse = status_go_accounts.multiAccountImportPrivateKey(privateKey)
    defaultAccount = self.getDefaultAccount()
    isPasswordOk = status_go_accounts.verifyAccountPassword(defaultAccount, password, KEYSTOREDIR)

  if not isPasswordOk:
    return

  self.saveAccount(
    accountResponse.result{"address"}.getStr,
    accountName,
    password,
    color,
    status_go_accounts.KEY,
    false,
    0,
    accountResponse.result{"accountId"}.getStr,
    accountResponse.result{"publicKey"}.getStr,
  )

method addAccountsFromSeed*(self: Service, seedPhrase: string, password: string, accountName: string, color: string) =
  let mnemonic = replace(seedPhrase, ',', ' ')
  let paths = @[PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET]
  let accountResponse = status_go_accounts.multiAccountImportMnemonic(mnemonic)
  let accountId = accountResponse.result{"id"}.getStr
  let deriveResponse = status_go_accounts.deriveAccounts(accountId, paths)

  let
    defaultAccount = self.getDefaultAccount()
    isPasswordOk = status_go_accounts.verifyAccountPassword(defaultAccount, password, KEYSTOREDIR)

  if not isPasswordOk:
    return

  self.saveAccount(
    deriveResponse.result[PATH_DEFAULT_WALLET]{"address"}.getStr,
    accountName,
    password,
    color,
    status_go_accounts.SEED,
    true,
    0,
    accountId,
    deriveResponse.result[PATH_DEFAULT_WALLET]{"publicKey"}.getStr
  )

method addWatchOnlyAccount*(self: Service, address: string, accountName: string, color: string) =
  self.saveAccount(address, accountName, "", color, status_go_accounts.WATCH, false)

method deleteAccount*(self: Service, address: string) =
  discard status_go_accounts.deleteAccount(address)
  let accountDeleted = self.accounts[address]
  self.accounts.del(address)

  self.events.emit("walletAccount/accountDeleted", AccountDeleted(account: accountDeleted))

method updateCurrency*(self: Service, newCurrency: string) =
  discard self.settingService.saveSetting("currency", newCurrency)

  self.events.emit("walletAccount/currencyUpdated", CurrencyUpdated())

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

  self.events.emit("walletAccount/walletAccountUpdated", WalletAccountUpdated(account: account))