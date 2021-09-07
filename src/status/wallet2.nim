import json, strformat, options, chronicles, sugar, sequtils, strutils

import libstatus/accounts as status_accounts
import libstatus/accounts/constants as constants
import libstatus/tokens as status_tokens
import libstatus/wallet as status_wallet
import libstatus/settings as status_settings
import libstatus/eth/[contracts]
import wallet2/[balance_manager, collectibles]
import wallet2/account as wallet_account
import ./types/[account, transaction, network, setting, gas_prediction, rpc_response]
import ../eventemitter
from web3/ethtypes import Address
from web3/conversions import `$`

export wallet_account, collectibles

logScope:
  topics = "status-wallet2"

type
  CryptoServicesArg* = ref object of Args
    services*: JsonNode # an array

type 
  StatusWalletController* = ref object
    events: EventEmitter
    accounts: seq[WalletAccount]
    tokens: seq[Erc20Contract]
    totalBalance*: float

# Forward declarations
proc initEvents*(self: StatusWalletController)
proc generateAccountConfiguredAssets*(self: StatusWalletController, 
  accountAddress: string): seq[Asset]
proc calculateTotalFiatBalance*(self: StatusWalletController)

proc setup(self: StatusWalletController, events: EventEmitter) = 
  self.events = events
  self.accounts = @[]
  self.tokens = @[]
  self.totalBalance = 0.0
  self.initEvents()

proc delete*(self: StatusWalletController) =
  discard

proc newStatusWalletController*(events: EventEmitter): 
  StatusWalletController =
  result = StatusWalletController()
  result.setup(events)

proc initTokens(self: StatusWalletController) =
  self.tokens = status_tokens.getVisibleTokens()

proc initAccounts(self: StatusWalletController) =
  let accounts = status_wallet.getWalletAccounts()
  for acc in accounts:
    var assets: seq[Asset] = self.generateAccountConfiguredAssets(acc.address)
    var walletAccount = newWalletAccount(acc.name, acc.address, acc.iconColor, 
    acc.path, acc.walletType, acc.publicKey, acc.wallet, acc.chat, assets)
    self.accounts.add(walletAccount)

proc init*(self: StatusWalletController) =
  self.initTokens()
  self.initAccounts()

proc initEvents*(self: StatusWalletController) = 
  self.events.on("currencyChanged") do(e: Args):
    self.events.emit("accountsUpdated", Args())

  self.events.on("newAccountAdded") do(e: Args):
    self.calculateTotalFiatBalance()

proc getAccounts*(self: StatusWalletController): seq[WalletAccount] =
  self.accounts

proc getDefaultCurrency*(self: StatusWalletController): string =
# TODO: this should come from a model? It is going to be used too in the
# profile section and ideally we should not call the settings more than once
  status_settings.getSetting[string](Setting.Currency, "usd")

proc generateAccountConfiguredAssets*(self: StatusWalletController, 
  accountAddress: string): seq[Asset] =
  var assets: seq[Asset] = @[]
  var asset = Asset(name:"Ethereum", symbol: "ETH", value: "0.0", 
  fiatBalanceDisplay: "0.0", accountAddress: accountAddress)
  assets.add(asset)
  for token in self.tokens:
    var symbol = token.symbol
    var existingToken = Asset(name: token.name, symbol: symbol, 
    value: fmt"0.0", fiatBalanceDisplay: "$0.0", accountAddress: accountAddress, 
      address: $token.address)
    assets.add(existingToken)
  assets

proc calculateTotalFiatBalance*(self: StatusWalletController) =
  self.totalBalance = 0.0
  for account in self.accounts:
    if account.realFiatBalance.isSome:
      self.totalBalance += account.realFiatBalance.get()

proc newAccount*(self: StatusWalletController, walletType: string, derivationPath: string, 
  name: string, address: string, iconColor: string, balance: string, 
  publicKey: string): WalletAccount =
  var assets: seq[Asset] = self.generateAccountConfiguredAssets(address)
  var account = WalletAccount(name: name, path: derivationPath, walletType: walletType, 
  address: address, iconColor: iconColor, balance: none[string](), assetList: assets, 
  realFiatBalance: none[float](), publicKey: publicKey)
  updateBalance(account, self.getDefaultCurrency())
  account

proc addNewGeneratedAccount(self: StatusWalletController, generatedAccount: GeneratedAccount, 
  password: string, accountName: string, color: string, accountType: string, 
  isADerivedAccount = true, walletIndex: int = 0) =
  try:
    generatedAccount.name = accountName
    var derivedAccount: DerivedAccount = status_accounts.saveAccount(generatedAccount, 
    password, color, accountType, isADerivedAccount, walletIndex)
    var account = self.newAccount(accountType, derivedAccount.derivationPath, 
    accountName, derivedAccount.address, color, fmt"0.00 {self.getDefaultCurrency()}", 
    derivedAccount.publicKey)

    self.accounts.add(account)
    # wallet_checkRecentHistory is required to be called when a new account is
    # added before wallet_getTransfersByAddress can be called. This is because
    # wallet_checkRecentHistory populates the status-go db that
    # wallet_getTransfersByAddress reads from
    discard status_wallet.checkRecentHistory(self.accounts.map(account => account.address))
    self.events.emit("newAccountAdded", wallet_account.AccountArgs(account: account))
  except Exception as e:
    raise newException(StatusGoException, fmt"Error adding new account: {e.msg}")

proc generateNewAccount*(self: StatusWalletController, password: string, accountName: string, color: string) =
  let
    walletRootAddress = status_settings.getSetting[string](Setting.WalletRootAddress, "")
    walletIndex = status_settings.getSetting[int](Setting.LatestDerivedPath) + 1
    loadedAccount = status_accounts.loadAccount(walletRootAddress, password)
    derivedAccount = status_accounts.deriveWallet(loadedAccount.id, walletIndex)
    generatedAccount = GeneratedAccount(
      id: loadedAccount.id,
      publicKey: derivedAccount.publicKey,
      address: derivedAccount.address
    )

  # if we've gotten here, the password is ok (loadAccount requires a valid password)
  # so no need to check for a valid password
  self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.GENERATED, true, walletIndex)
  
  let statusGoResult = status_settings.saveSetting(Setting.LatestDerivedPath, $walletIndex)
  if statusGoResult.error != "":
    error "Error storing the latest wallet index", msg=statusGoResult.error

proc addAccountsFromSeed*(self: StatusWalletController, seed: string, password: string, accountName: string, color: string) =
  let mnemonic = replace(seed, ',', ' ')
  var generatedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
  generatedAccount.derived = status_accounts.deriveAccounts(generatedAccount.id)

  let
    defaultAccount = status_accounts.getDefaultAccount()
    isPasswordOk = status_accounts.verifyAccountPassword(defaultAccount, password)
  if not isPasswordOk:
    raise newException(StatusGoException, "Error generating new account: invalid password")

  self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.SEED)

proc addAccountsFromPrivateKey*(self: StatusWalletController, privateKey: string, password: string, accountName: string, color: string) =
  let
    generatedAccount = status_accounts.MultiAccountImportPrivateKey(privateKey)
    defaultAccount = status_accounts.getDefaultAccount()
    isPasswordOk = status_accounts.verifyAccountPassword(defaultAccount, password)

  if not isPasswordOk:
    raise newException(StatusGoException, "Error generating new account: invalid password")

  self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.KEY, false)

proc addWatchOnlyAccount*(self: StatusWalletController, address: string, accountName: string, color: string) =
  let account = GeneratedAccount(address: address)
  self.addNewGeneratedAccount(account, "", accountName, color, constants.WATCH, false)

proc changeAccountSettings*(self: StatusWalletController, address: string, accountName: string, color: string): string =
  var selectedAccount: WalletAccount
  for account in self.accounts:
    if (account.address == address):
      selectedAccount = account
      break
  if (isNil(selectedAccount)):
    result = "No account found with that address"
    error "No account found with that address", address
  selectedAccount.name = accountName
  selectedAccount.iconColor = color
  result = status_accounts.changeAccount(selectedAccount.name, selectedAccount.address, 
  selectedAccount.publicKey, selectedAccount.walletType, selectedAccount.iconColor)

proc deleteAccount*(self: StatusWalletController, address: string): string =
  result = status_accounts.deleteAccount(address)
  self.accounts = self.accounts.filter(acc => acc.address.toLowerAscii != address.toLowerAscii)

proc getOpenseaCollections*(address: string): string =
  result = status_wallet.getOpenseaCollections(address)

proc getOpenseaAssets*(address: string, collectionSlug: string, limit: int): string =
  result = status_wallet.getOpenseaAssets(address, collectionSlug, limit)

proc onAsyncFetchCryptoServices*(self: StatusWalletController, response: string) =
  let responseArray = response.parseJson
  if (responseArray.kind != JArray):
    info "received crypto services is not a json array"
    self.events.emit("cryptoServicesFetched", CryptoServicesArg())
    return

  self.events.emit("cryptoServicesFetched", CryptoServicesArg(services: responseArray))