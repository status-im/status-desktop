import NimQml
# import eventemitter
import strformat
import strutils
import chronicles

import view
import views/asset_list
import views/account_list
import ../../status/libstatus/wallet as status_wallet
import ../../signals/types

import ../../status/wallet
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
  let accounts = status_wallet.getAccounts()

  var totalAccountBalance: float = 0

  const symbol = "ETH"
  for address in accounts:
    let eth_balance = self.status.wallet.getEthBalance(address)
    # TODO get all user assets and add them to balance
    let usd_balance = self.status.wallet.getFiatValue(eth_balance, symbol, "USD")

    totalAccountBalance = totalAccountBalance + usd_balance

    let assetList = newAssetList()
    let asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"{eth_balance:.6}", fiatValue: "$" & fmt"{usd_balance:.2f}", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
    assetList.addAssetToList(asset)

    let account = Account(name: "Status Account", address: address, iconColor: "", balance: fmt"{totalAccountBalance:.2f} USD", assetList: assetList)
    self.view.addAccountToList(account)

  self.view.setDefaultAccount(accounts[0])

method onSignal(self: WalletController, data: Signal) =
  debug "New signal received"
  discard
