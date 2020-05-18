import NimQml
import strformat
import strutils

import walletView
import ../../status/wallet as status_wallet
import ../signals/types

type WalletController* = ref object of SignalSubscriber
  view*: WalletView
  variant*: QVariant

proc newController*(): WalletController =
  echo "new wallet"
  result = WalletController()
  result.view = newWalletView()
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

  let symbol = "ETH"
  self.view.addAssetToList("Ethereum", symbol, fmt"{eth_value:.6}", "$" & fmt"{usd_balance:.6}", fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")

method onSignal(self: WalletController, data: Signal) =
  var msg = cast[WalletSignal](data)
  self.view.setLastMessage(msg.content)