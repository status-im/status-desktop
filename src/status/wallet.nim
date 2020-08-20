import eventemitter, json, strformat, strutils, chronicles, sequtils, httpclient, tables
import json_serialization, stint
from eth/common/utils import parseAddress
import libstatus/accounts as status_accounts
import libstatus/tokens as status_tokens
import libstatus/settings as status_settings
import libstatus/wallet as status_wallet
import libstatus/accounts/constants as constants
import libstatus/contracts as contracts
from libstatus/types import GeneratedAccount, DerivedAccount, Transaction, Setting, GasPricePrediction, EthSend, Quantity, `%`, StatusGoException
from libstatus/utils as libstatus_utils import eth2Wei, gwei2Wei, first, toUInt64
import wallet/balance_manager
import wallet/account
import wallet/collectibles
export account, collectibles
export Transaction

logScope:
  topics = "wallet-model"

type WalletModel* = ref object
    events*: EventEmitter
    accounts*: seq[WalletAccount]
    defaultCurrency*: string
    tokens*: JsonNode
    totalBalance*: float

proc getDefaultCurrency*(self: WalletModel): string
proc calculateTotalFiatBalance*(self: WalletModel)

proc newWalletModel*(events: EventEmitter): WalletModel =
  result = WalletModel()
  result.accounts = @[]
  result.tokens = %* []
  result.events = events
  result.defaultCurrency = ""
  result.totalBalance = 0.0

proc initEvents*(self: WalletModel) =
 self.events.on("currencyChanged") do(e: Args):
    self.defaultCurrency = self.getDefaultCurrency()
    for account in self.accounts:
      updateBalance(account, self.getDefaultCurrency())
    self.calculateTotalFiatBalance()
    self.events.emit("accountsUpdated", Args())

 self.events.on("newAccountAdded") do(e: Args):
   self.calculateTotalFiatBalance()

proc delete*(self: WalletModel) =
  discard

proc sendTransaction*(self: WalletModel, source, to, assetAddress, value, gas, gasPrice, password: string): string =
  var
    weiValue = eth2Wei(parseFloat(value), 18) # ETH
    data = ""
    toAddr = parseAddress(to)
  let gasPriceInWei = gwei2Wei(parseFloat(gasPrice))

  # TODO: this code needs to be tested with testnet assets (to be implemented in
  # a future PR
  if assetAddress != ZERO_ADDRESS and not assetAddress.isEmptyOrWhitespace:
    let
      token = self.tokens.first("address", assetAddress)
      contract = getContract("snt")
      transfer = Transfer(to: toAddr, value: weiValue)
    weiValue = eth2Wei(parseFloat(value), token["decimals"].getInt)
    data = contract.methods["transfer"].encodeAbi(transfer)
    toAddr = parseAddress(assetAddress)

  let tx = EthSend(
    source: parseAddress(source),
    to: toAddr.some,
    gas: (if gas.isEmptyOrWhitespace: Quantity.none else: Quantity(cast[uint64](parseFloat(gas).toUInt64)).some),
    gasPrice: (if gasPrice.isEmptyOrWhitespace: int.none else: gwei2Wei(parseFloat(gasPrice)).truncate(int).some),
    value: weiValue.some,
    data: data
  )
  try:
    result = status_wallet.sendTransaction(tx, password)
  except StatusGoException as e:
    raise

proc getDefaultCurrency*(self: WalletModel): string =
  # TODO: this should come from a model? It is going to be used too in the
  # profile section and ideally we should not call the settings more than once
  status_settings.getSetting[string](Setting.Currency, "usd")

proc setDefaultCurrency*(self: WalletModel, currency: string) =
  discard status_settings.saveSetting(Setting.Currency, currency)
  self.events.emit("currencyChanged", CurrencyArgs(currency: currency))

proc generateAccountConfiguredAssets*(self: WalletModel, accountAddress: string): seq[Asset] =
  var assets: seq[Asset] = @[]
  var asset = Asset(name:"Ethereum", symbol: "ETH", value: "0.0", fiatBalanceDisplay: "0.0", accountAddress: accountAddress)
  assets.add(asset)
  for token in self.tokens:
    var symbol = token["symbol"].getStr
    var existingToken = Asset(name: token["name"].getStr, symbol: symbol, value: fmt"0.0", fiatBalanceDisplay: "$0.0", accountAddress: accountAddress, address: token["address"].getStr)
    assets.add(existingToken)
  assets

proc populateAccount*(self: WalletModel, walletAccount: var WalletAccount, balance: string) =
  var assets: seq[Asset] = self.generateAccountConfiguredAssets(walletAccount.address)
  walletAccount.balance = fmt"{balance} {self.defaultCurrency}"
  walletAccount.assetList = assets
  walletAccount.realFiatBalance = 0.0
  updateBalance(walletAccount, self.getDefaultCurrency())

proc newAccount*(self: WalletModel, name: string, address: string, iconColor: string, balance: string, publicKey: string): WalletAccount =
  var assets: seq[Asset] = self.generateAccountConfiguredAssets(address)
  var account = WalletAccount(name: name, address: address, iconColor: iconColor, balance: fmt"{balance} {self.defaultCurrency}", assetList: assets, realFiatBalance: 0.0, publicKey: publicKey)
  updateBalance(account, self.getDefaultCurrency())
  account

proc initAccounts*(self: WalletModel) =
  self.tokens = status_tokens.getCustomTokens()
  let accounts = status_wallet.getWalletAccounts()
  for account in accounts:
    var acc = WalletAccount(account)
    self.populateAccount(acc, "")
    self.accounts.add(acc)

proc getTotalFiatBalance*(self: WalletModel): string =
  var newBalance = 0.0
  fmt"{self.totalBalance:.2f} {self.defaultCurrency}"

proc convertValue*(self: WalletModel, balance: string, fromCurrency: string, toCurrency: string): float =
  result = convertValue(balance, fromCurrency, toCurrency)

proc calculateTotalFiatBalance*(self: WalletModel) =
  self.totalBalance = 0.0
  for account in self.accounts:
    self.totalBalance += account.realFiatBalance

proc addNewGeneratedAccount(self: WalletModel, generatedAccount: GeneratedAccount, password: string, accountName: string, color: string, accountType: string, isADerivedAccount = true, walletIndex: int = 0): string =
  try:
    generatedAccount.name = accountName
    var derivedAccount: DerivedAccount = status_accounts.saveAccount(generatedAccount, password, color, accountType, isADerivedAccount, walletIndex)
    var account = self.newAccount(accountName, derivedAccount.address, color, fmt"0.00 {self.defaultCurrency}", derivedAccount.publicKey)
    self.accounts.add(account)
    self.events.emit("newAccountAdded", AccountArgs(account: account))
  except Exception as e:
    return fmt"Error adding new account: {e.msg}"

  return ""

proc addNewGeneratedAccountWithPassword(self: WalletModel, generatedAccount: GeneratedAccount, password: string, accountName: string, color: string, accountType: string, isADerivedAccount = true, walletIndex: int = 0): string =
  let defaultAccount = status_accounts.getDefaultAccount()
  let isPasswordOk = status_accounts.verifyAccountPassword(defaultAccount, password)

  if (not isPasswordOk):
    return "Wrong password"
  result = self.addNewGeneratedAccount(generatedAccount, password, accountName, color, accountType, isADerivedAccount, walletIndex)

proc generateNewAccount*(self: WalletModel, password: string, accountName: string, color: string): string =
  let walletRootAddress = status_settings.getSetting[string](Setting.WalletRootAddress, "")
  let walletIndex = status_settings.getSetting[int](Setting.LatestDerivedPath) + 1
  let loadedAccount = status_accounts.loadAccount(walletRootAddress, password)
  let derivedAccount = status_accounts.deriveWallet(loadedAccount.id, walletIndex)

  let generatedAccount = GeneratedAccount(
    id: loadedAccount.id,
    publicKey: derivedAccount.publicKey,
    address: derivedAccount.address
  )

  result = self.addNewGeneratedAccountWithPassword(generatedAccount, password, accountName, color, constants.GENERATED, true, walletIndex)
  
  let statusGoResult = status_settings.saveSetting(Setting.LatestDerivedPath, $walletIndex)
  if statusGoResult.error != "":
    error "Error storing the latest wallet index", msg=statusGoResult.error

proc addAccountsFromSeed*(self: WalletModel, seed: string, password: string, accountName: string, color: string): string =
  let mnemonic = replace(seed, ',', ' ')
  let generatedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
  return self.addNewGeneratedAccountWithPassword(generatedAccount, password, accountName, color, constants.SEED)

proc addAccountsFromPrivateKey*(self: WalletModel, privateKey: string, password: string, accountName: string, color: string): string =
  let generatedAccount = status_accounts.MultiAccountImportPrivateKey(privateKey)
  return self.addNewGeneratedAccountWithPassword(generatedAccount, password, accountName, color, constants.KEY, false)

proc addWatchOnlyAccount*(self: WalletModel, address: string, accountName: string, color: string): string =
  let account = GeneratedAccount(address: address)
  return self.addNewGeneratedAccount(account, "", accountName, color, constants.WATCH, false)

proc hasAsset*(self: WalletModel, account: string, symbol: string): bool =
  self.tokens.anyIt(it["symbol"].getStr == symbol)

proc changeAccountSettings*(self: WalletModel, address: string, accountName: string, color: string): string =
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
  result = status_accounts.changeAccount(selectedAccount)

proc deleteAccount*(self: WalletModel, address: string): string =
  result = status_accounts.deleteAccount(address)

proc toggleAsset*(self: WalletModel, symbol: string, enable: bool, address: string, name: string, decimals: int, color: string) =
  self.tokens = addOrRemoveToken(enable, address, name, symbol, decimals, color)
  for account in self.accounts:
    account.assetList = self.generateAccountConfiguredAssets(account.address)
    updateBalance(account, self.getDefaultCurrency())
  self.events.emit("assetChanged", Args())

proc getTransfersByAddress*(self: WalletModel, address: string): seq[Transaction] =
 result = status_wallet.getTransfersByAddress(address)

proc validateMnemonic*(self: WalletModel, mnemonic: string): string =
  result = status_wallet.validateMnemonic(mnemonic).parseJSON()["error"].getStr

proc getGasPricePredictions*(self: WalletModel): GasPricePrediction =
  try:
    let url: string = fmt"https://etherchain.org/api/gasPriceOracle"
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })
    let response = client.request(url)
    result = Json.decode(response.body, GasPricePrediction)
  except Exception as e:
    echo "error getting gas price predictions"
    echo e.msg

