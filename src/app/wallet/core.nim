import NimQml
import eventemitter
import strformat
import strutils

import walletView
import ../../status/wallet as status_wallet
import ../../models/wallet
import ../signals/types

var sendTransaction = proc(from_value: string, to: string, value: string, password: string): string =
  status_wallet.sendTransaction(from_value, to, value, password)

type WalletController* = ref object of SignalSubscriber
  model: WalletModel
  view*: WalletView
  variant*: QVariant

proc newController*(events: EventEmitter): WalletController =
  result = WalletController()
  result.model = newWalletModel(events)
  result.view = newWalletView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: WalletController) =
  delete self.view
  delete self.variant

proc init*(self: WalletController) =
  # 1. get balance of an address
  var balance = status_wallet.getBalance("0x0000000000000000000000000000000000000000")
  echo(fmt"balance in hex: {balance}")

  # 2. convert balance to eth
  var eth_value = status_wallet.hex2Eth(balance)
  echo(fmt"balance in eth: {eth_value}")

  # 3. get usd price of 1 eth
  var usd_eth_price = status_wallet.getPrice("ETH", "USD")
  echo(fmt"usd_price: {usd_eth_price}")

  # 4. convert balance to usd
  var usd_balance = parseFloat(eth_value) * parseFloat(usd_eth_price)
  echo(fmt"balance in usd: {usd_balance}")

  self.view.setDefaultAccount(status_wallet.getAccount())

  var symbol = "ETH"
  var asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"{eth_value:.6}", fiatValue: "$" & fmt"{usd_balance:.6}", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")

  self.view.addAssetToList(asset)
