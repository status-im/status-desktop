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

type WalletModel* = ref object
    events*: EventEmitter

proc newWalletModel*(): WalletModel =
  result = WalletModel()
  result.events = createEventEmitter()

proc delete*(self: WalletModel) =
  discard

proc sendTransaction*(self: WalletModel, from_value: string, to: string, value: string, password: string): string =
  status_wallet.sendTransaction(from_value, to, value, password)

proc getEthBalance*(self: WalletModel, address: string): string =
  var balance = status_wallet.getBalance(address)
  echo(fmt"balance in hex: {balance}")

  # 2. convert balance to eth
  var eth_value = status_wallet.hex2Eth(balance)
  echo(fmt"balance in eth: {eth_value}")
  eth_value

proc getDefaultCurrency*(self: WalletModel): string =
  status_settings.getSettings().parseJSON()["result"]["currency"].getStr

proc setDefaultCurrency*(self: WalletModel, currency: string) =
  discard status_settings.saveSettings("currency", currency)
  self.events.emit("currencyChanged", CurrencyArgs(currency: currency))

proc getFiatValue*(self: WalletModel, eth_balance: string, symbol: string, fiat_symbol: string): float =
  # 3. get usd price of 1 eth
  var fiat_eth_price = status_wallet.getPrice("ETH", fiat_symbol)
  echo(fmt"fiat_price: {fiat_eth_price}")

  # 4. convert balance to usd
  var fiat_balance = parseFloat(eth_balance) * parseFloat(fiat_eth_price)
  echo(fmt"balance in usd: {fiat_balance}")
  fiat_balance
