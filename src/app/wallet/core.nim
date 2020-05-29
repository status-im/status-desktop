import NimQml
import eventemitter
import strformat
import strutils
import chronicles

import view
import ../../status/libstatus/wallet as status_wallet
import ../../status/wallet
import ../../signals/types

import ../../status/status

type WalletController* = ref object of SignalSubscriber
  status: Status
  view*: WalletView
  variant*: QVariant

proc newController*(status: Status): WalletController =
  result = WalletController()
  result.status = status
  result.view = newWalletView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: WalletController) =
  delete self.view
  delete self.variant

proc init*(self: WalletController) =
  var symbol = "ETH"
  var eth_balance = self.status.wallet.getEthBalance("0x0000000000000000000000000000000000000000")
  var usd_balance = self.status.wallet.getFiatValue(eth_balance, symbol, "USD")

  var asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"{eth_balance:.6}", fiatValue: "$" & fmt"{usd_balance:.6}", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
  self.view.addAssetToList(asset)

  self.view.setDefaultAccount(status_wallet.getAccount())

method onSignal(self: WalletController, data: Signal) =
  debug "New signal received"
  discard
