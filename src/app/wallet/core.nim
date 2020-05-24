import NimQml
import eventemitter
import strformat
import strutils

import view
import ../../status/wallet as status_wallet
import ../../models/wallet
import ../../signals/types

type WalletController* = ref object of SignalSubscriber
  model: WalletModel
  view*: WalletView
  variant*: QVariant
  appEvents*: EventEmitter

proc newController*(appEvents: EventEmitter): WalletController =
  result = WalletController()
  result.appEvents = appEvents
  result.model = newWalletModel()
  result.view = newWalletView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: WalletController) =
  delete self.view
  delete self.variant

proc init*(self: WalletController) =
  var symbol = "ETH"
  var eth_balance = self.model.getEthBalance("0x0000000000000000000000000000000000000000")
  var usd_balance = self.model.getFiatValue(eth_balance, symbol, "USD")

  var asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"{eth_balance:.6}", fiatValue: "$" & fmt"{usd_balance:.6}", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
  self.view.addAssetToList(asset)

  self.view.setDefaultAccount(status_wallet.getAccount())
