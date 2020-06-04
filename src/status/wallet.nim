import eventemitter
import json
import strformat
import strutils
import libstatus/wallet as status_wallet
import libstatus/settings as status_settings

type CurrencyArgs* = ref object of Args
    currency*: string

type Asset* = ref object
    name*, symbol*, value*, fiatValue*, image*: string

type Account* = ref object
    name*, address*, iconColor*, balance*: string
    realFiatBalance*: float
    assetList*: seq[Asset]

type WalletModel* = ref object
    events*: EventEmitter
    accounts*: seq[Account]

proc updateBalance*(self: Account)

proc newWalletModel*(events: EventEmitter): WalletModel =
  result = WalletModel()
  result.accounts = @[]
  result.events = events

proc initEvents*(self: WalletModel) =
  self.events.on("currencyChanged") do(e: Args):
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
  (symbol == "DAI") or (symbol == "OMG")

proc updateBalance*(self: Account) =
  let defaultCurrency = getDefaultCurrency()
  const symbol = "ETH"
  let eth_balance = getEthBalance(self.address)
  let usd_balance = getFiatValue(eth_balance, symbol, defaultCurrency)
  var totalAccountBalance = usd_balance
  self.balance = fmt"{totalAccountBalance:.2f} {defaultCurrency}"

proc initAccounts*(self: WalletModel) =
  let accounts = status_wallet.getAccounts()

  var totalAccountBalance: float = 0
  const symbol = "ETH"
  let defaultCurrency = getDefaultCurrency()

  for address in accounts:
    let eth_balance = getEthBalance(address)
    let usd_balance = getFiatValue(eth_balance, symbol, defaultCurrency)

    totalAccountBalance = totalAccountBalance + usd_balance

    var asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"{eth_balance:.6}", fiatValue: "$" & fmt"{usd_balance:.2f}", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
    var assets: seq[Asset] = @[]
    assets.add(asset)

    var account = Account(name: "Status Account", address: address, iconColor: "", balance: "", assetList: assets, realFiatBalance: totalAccountBalance)
    account.updateBalance()
    self.accounts.add(account)
