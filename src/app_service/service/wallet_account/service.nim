import Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils
import web3/[ethtypes, conversions]

import ../setting/service as setting_service
import ../token/service as token_service

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


proc getPrice(crypto: string, fiat: string): string =
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

type
  Service* = ref object of service_interface.ServiceInterface
    settingService: setting_service.Service
    tokenService: token_service.Service
    accounts: Table[string, WalletAccountDto]

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.Service, tokenService: token_service.Service): Service =
  result = Service()
  result.settingService = settingService
  result.tokenService = tokenService
  result.accounts = initTable[string, WalletAccountDto]()

method buildTokens(
  self: Service,
  account: WalletAccountDto,
  tokens: seq[TokenDto],
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

  for token in tokens:
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

method init*(self: Service) =
  try:
    let response = status_go_accounts.getAccounts()
    let accounts = map(
      response.result.getElems(),
      proc(x: JsonNode): WalletAccountDto = x.toWalletAccountDto()
    )
    let currency = self.settingService.getSetting().currency
    let tokens = self.tokenService.getTokens().filter(t => t.isVisible)
    var prices = {"ETH": parsefloat(getPrice("ETH", currency))}.toTable
    for token in tokens:
      prices[token.symbol] = parsefloat(getPrice(token.symbol, currency))

    for account in accounts:
      account.tokens = self.buildTokens(account, tokens, prices)
      self.accounts[account.address] = account

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getWalletAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values).filter(a => a.isChat)

method getWalletAccount*(self: Service, accountIndex: int): WalletAccountDto =
  return self.getWalletAccounts()[accountIndex]

method getCurrencyBalance*(self: Service): float64 =
  return self.getWalletAccounts().map(a => a.getCurrencyBalance()).foldl(a + b, 0.0)

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

method generateNewAccount*(self: Service, password: string, accountName: string, color: string) =
  discard

method addAccountsFromPrivateKey*(self: Service, privateKey: string, password: string, accountName: string, color: string) =
  discard

method addAccountsFromSeed*(self: Service, seedPhrase: string, password: string, accountName: string, color: string) =
  discard

method addWatchOnlyAccount*(self: Service, address: string, accountName: string, color: string) =
  self.saveAccount(address, accountName, "", color, status_go_accounts.WATCH, false)

method deleteAccount*(self: Service, address: string) =
  discard status_go_accounts.deleteAccount(address)
  self.accounts.del(address)


#   proc addNewGeneratedAccount(self: WalletModel, generatedAccount: GeneratedAccount, password: string, accountName: string, color: string, accountType: string, isADerivedAccount = true, walletIndex: int = 0) =
#   try:
#     generatedAccount.name = accountName
#     var derivedAccount: DerivedAccount = status_accounts.saveAccount(generatedAccount, password, color, accountType, isADerivedAccount, walletIndex)
#     var account = self.newAccount(accountType, derivedAccount.derivationPath, accountName, derivedAccount.address, color, fmt"0.00 {self.defaultCurrency}", derivedAccount.publicKey)
#     self.accounts.add(account)
#     # wallet_checkRecentHistory is required to be called when a new account is
#     # added before wallet_getTransfersByAddress can be called. This is because
#     # wallet_checkRecentHistory populates the status-go db that
#     # wallet_getTransfersByAddress reads from
#     discard status_wallet.checkRecentHistory(self.accounts.map(account => account.address))
#     self.events.emit("newAccountAdded", wallet_account.AccountArgs(account: account))
#   except Exception as e:
#     raise newException(StatusGoException, fmt"Error adding new account: {e.msg}")

# proc generateNewAccount*(self: WalletModel, password: string, accountName: string, color: string) =
#   let
#     walletRootAddress = status_settings.getSetting[string](Setting.WalletRootAddress, "")
#     walletIndex = status_settings.getSetting[int](Setting.LatestDerivedPath) + 1
#     loadedAccount = status_accounts.loadAccount(walletRootAddress, password)
#     derivedAccount = status_accounts.deriveWallet(loadedAccount.id, walletIndex)
#     generatedAccount = GeneratedAccount(
#       id: loadedAccount.id,
#       publicKey: derivedAccount.publicKey,
#       address: derivedAccount.address
#     )

#   # if we've gotten here, the password is ok (loadAccount requires a valid password)
#   # so no need to check for a valid password
#   self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.GENERATED, true, walletIndex)
  
#   let statusGoResult = status_settings.saveSetting(Setting.LatestDerivedPath, $walletIndex)
#   if statusGoResult.error != "":
#     error "Error storing the latest wallet index", msg=statusGoResult.error

# proc addAccountsFromSeed*(self: WalletModel, seed: string, password: string, accountName: string, color: string, keystoreDir: string) =
#   let mnemonic = replace(seed, ',', ' ')
#   var generatedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
#   generatedAccount.derived = status_accounts.deriveAccounts(generatedAccount.id)
 
#   let
#     defaultAccount = eth.getDefaultAccount()
#     isPasswordOk = status_accounts.verifyAccountPassword(defaultAccount, password, keystoreDir)
#   if not isPasswordOk:
#     raise newException(StatusGoException, "Error generating new account: invalid password")

#   self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.SEED)

# proc addAccountsFromPrivateKey*(self: WalletModel, privateKey: string, password: string, accountName: string, color: string, keystoreDir: string) =
#   let
#     generatedAccount = status_accounts.MultiAccountImportPrivateKey(privateKey)
#     defaultAccount = eth.getDefaultAccount()
#     isPasswordOk = status_accounts.verifyAccountPassword(defaultAccount, password, keystoreDir)

#   if not isPasswordOk:
#     raise newException(StatusGoException, "Error generating new account: invalid password")

#   self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.KEY, false)