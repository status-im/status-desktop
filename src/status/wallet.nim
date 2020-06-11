import eventemitter, json, strformat, strutils, chronicles, sequtils
import libstatus/accounts as status_accounts
import libstatus/tokens as status_tokens
import libstatus/settings as status_settings
import libstatus/wallet as status_wallet
import libstatus/accounts/constants as constants
from libstatus/types import GeneratedAccount, DerivedAccount
import wallet/balance_manager
import wallet/account
export account

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

proc sendTransaction*(self: WalletModel, from_value: string, to: string, value: string, password: string): string =
  status_wallet.sendTransaction(from_value, to, value, password)

proc getDefaultCurrency*(self: WalletModel): string =
  status_settings.getSettings().parseJSON()["result"]["currency"].getStr

proc setDefaultCurrency*(self: WalletModel, currency: string) =
  discard status_settings.saveSettings("currency", currency)
  self.events.emit("currencyChanged", CurrencyArgs(currency: currency))

proc generateAccountConfiguredAssets*(self: WalletModel, accountAddress: string): seq[Asset] =
  var assets: seq[Asset] = @[]
  var asset = Asset(name:"Ethereum", symbol: "ETH", value: "0.0", fiatValue: "0.0", accountAddress: accountAddress)
  assets.add(asset)
  for token in self.tokens:
    var symbol = token["symbol"].getStr
    var existingToken = Asset(name: token["name"].getStr, symbol: symbol, value: fmt"0.0", fiatValue: "$0.0", accountAddress: accountAddress, address: token["address"].getStr)
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
  self.calculateTotalFiatBalance

proc getTotalFiatBalance*(self: WalletModel): string =
  var newBalance = 0.0
  fmt"{self.totalBalance:.2f} {self.defaultCurrency}"

proc calculateTotalFiatBalance*(self: WalletModel) =
  self.totalBalance = 0.0
  for account in self.accounts:
    self.totalBalance += account.realFiatBalance

proc addNewGeneratedAccount(self: WalletModel, generatedAccount: GeneratedAccount, password: string, accountName: string, color: string, accountType: string, isADerivedAccount = true) =
  generatedAccount.name = accountName
  var derivedAccount: DerivedAccount = status_accounts.saveAccount(generatedAccount, password, color, accountType, isADerivedAccount)
  var account = self.newAccount(accountName, derivedAccount.address, color, fmt"0.00 {self.defaultCurrency}", derivedAccount.publicKey)
  self.accounts.add(account)
  self.events.emit("newAccountAdded", AccountArgs(account: account))

proc generateNewAccount*(self: WalletModel, password: string, accountName: string, color: string) =
  let accounts = status_accounts.generateAddresses(1)
  let generatedAccount = accounts[0]
  self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.GENERATED)

proc addAccountsFromSeed*(self: WalletModel, seed: string, password: string, accountName: string, color: string) =
  let mnemonic = replace(seed, ',', ' ')
  let generatedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
  self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.SEED)

proc addAccountsFromPrivateKey*(self: WalletModel, privateKey: string, password: string, accountName: string, color: string) =
  let generatedAccount = status_accounts.MultiAccountImportPrivateKey(privateKey)
  self.addNewGeneratedAccount(generatedAccount, password, accountName, color, constants.KEY, false)

proc addWatchOnlyAccount*(self: WalletModel, address: string, accountName: string, color: string) =
  let account = GeneratedAccount(address: address)
  self.addNewGeneratedAccount(account, "", accountName, color, constants.WATCH, false)

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
