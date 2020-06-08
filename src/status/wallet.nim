import eventemitter
import json
import strformat
import strutils
import libstatus/wallet as status_wallet
import libstatus/settings as status_settings
import libstatus/accounts as status_accounts
import libstatus/accounts/constants as constants
import libstatus/types
import chronicles
import libstatus/tokens as status_tokens

type CurrencyArgs* = ref object of Args
    currency*: string

type Asset* = ref object
    name*, symbol*, value*, fiatValue*, image*: string

type Account* = ref object
    name*, address*, iconColor*, balance*: string
    realFiatBalance*: float
    assetList*: seq[Asset]

type AccountArgs* = ref object of Args
    account*: Account

type WalletModel* = ref object
    events*: EventEmitter
    accounts*: seq[Account]
    defaultCurrency*: string
    tokens*: JsonNode

proc updateBalance*(self: Account)
proc getDefaultCurrency*(self: WalletModel): string

proc newWalletModel*(events: EventEmitter): WalletModel =
  result = WalletModel()
  result.accounts = @[]
  result.tokens = %* []
  result.events = events
  result.defaultCurrency = ""

proc initEvents*(self: WalletModel) =
 self.events.on("currencyChanged") do(e: Args):
    self.defaultCurrency = self.getDefaultCurrency()
    for account in self.accounts:
      account.updateBalance()
    self.events.emit("accountsUpdated", Args())

proc delete*(self: WalletModel) =
  discard

proc sendTransaction*(self: WalletModel, from_value: string, to: string, value: string, password: string): string =
  status_wallet.sendTransaction(from_value, to, value, password)

proc getEthBalance*(address: string): string =
  var balance = status_wallet.getBalance(address)
  echo(fmt"balance in hex: {balance}")

  # 2. convert balance to eth
  var eth_value = status_wallet.hex2Eth(balance)
  echo(fmt"balance in eth: {eth_value}")
  eth_value

proc getDefaultCurrency*(): string =
  status_settings.getSettings().parseJSON()["result"]["currency"].getStr

proc getDefaultCurrency*(self: WalletModel): string =
  getDefaultCurrency()

proc setDefaultCurrency*(self: WalletModel, currency: string) =
  discard status_settings.saveSettings("currency", currency)
  self.events.emit("currencyChanged", CurrencyArgs(currency: currency))

proc getFiatValue*(eth_balance: string, symbol: string, fiat_symbol: string): float =
  if eth_balance == "0.0": return 0.0
  # 3. get usd price of 1 eth
  var fiat_eth_price = status_wallet.getPrice("ETH", fiat_symbol)
  echo(fmt"fiat_price: {fiat_eth_price}")

  # 4. convert balance to usd
  var fiat_balance = parseFloat(eth_balance) * parseFloat(fiat_eth_price)
  echo(fmt"balance in usd: {fiat_balance}")
  fiat_balance

proc hasAsset*(self: WalletModel, account: string, symbol: string): bool =
  for token in self.tokens:
    if symbol == token["symbol"].getStr:
      return true
  return false

proc updateBalance*(self: Account) =
  let defaultCurrency = getDefaultCurrency()
  const symbol = "ETH"
  let eth_balance = getEthBalance(self.address)
  let usd_balance = getFiatValue(eth_balance, symbol, defaultCurrency)
  var totalAccountBalance = usd_balance
  self.balance = fmt"{totalAccountBalance:.2f} {defaultCurrency}"

proc generateAccountConfiguredAssets*(self: WalletModel): seq[Asset] =
  var assets: seq[Asset] = @[]
  var symbol = "ETH"
  var asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"0.0", fiatValue: "$" & fmt"0.0", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
  assets.add(asset)
  for token in self.tokens:
    var symbol = token["symbol"].getStr
    var existingToken = Asset(name: token["name"].getStr, symbol: symbol, value: fmt"0.0", fiatValue: "$0.0", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
    assets.add(existingToken)
  assets

proc initAccounts*(self: WalletModel) =
  self.tokens = status_tokens.getCustomTokens()
  let accounts = status_wallet.getWalletAccounts()

  var totalAccountBalance: float = 0
  const symbol = "ETH"
  let defaultCurrency = getDefaultCurrency()

  for account in accounts:
    let address = account.address
    let eth_balance = getEthBalance(address)
    let usd_balance = getFiatValue(eth_balance, symbol, defaultCurrency)

    totalAccountBalance = totalAccountBalance + usd_balance

    var assets: seq[Asset] = self.generateAccountConfiguredAssets()

    var account = Account(name: account.name, address: address, iconColor: account.color, balance: "", assetList: assets, realFiatBalance: totalAccountBalance)
    account.updateBalance()
    self.accounts.add(account)

proc getTotalFiatBalance*(self: WalletModel): string =
  var newBalance = 0.0
  fmt"{newBalance:.2f} {self.defaultCurrency}"

proc addNewGeneratedAccount(self: WalletModel, generatedAccount: GeneratedAccount, password: string, accountName: string, color: string, accountType: string) =
  generatedAccount.name = accountName

  var derivedAccount: DerivedAccount
  try:
    derivedAccount = status_accounts.saveAccount(generatedAccount, password, color, accountType)
  except:
    error "Error storing the new account. Bad password?"
    return

  var symbol = "SNT"
  var asset = Asset(name:"Status", symbol: symbol, value: fmt"0.0", fiatValue: "$" & fmt"0.0", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")

  var assets: seq[Asset] = self.generateAccountConfiguredAssets()
  var account = Account(name: accountName, address: derivedAccount.address, iconColor: color, balance: fmt"0.00 {self.defaultCurrency}", assetList: assets, realFiatBalance: 0.0)

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

proc toggleAsset*(self: WalletModel, symbol: string, enable: bool, address: string, name: string, decimals: int, color: string) =
  if enable:
    discard status_tokens.addCustomToken(address, name, symbol, decimals, color)
  else:
    discard status_tokens.removeCustomToken(address)
  self.tokens = status_tokens.getCustomTokens()
  for account in self.accounts:
    var assets: seq[Asset] = self.generateAccountConfiguredAssets()
    account.assetList = assets
  self.events.emit("assetChanged", Args())
