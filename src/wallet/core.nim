import NimQml
import strformat
import strutils

import walletView
import ../status/wallet as status_wallet

type Wallet* = ref object
  assetsModel*: AssetsModel
  assetsVariant*: QVariant

proc newWallet*(): Wallet =
  echo "new wallet"
  result = Wallet()
  result.assetsModel = newAssetsModel()
  result.assetsVariant = newQVariant(result.assetsModel)

proc delete*(self: Wallet) =
  delete self.assetsModel
  delete self.assetsVariant

proc init*(self: Wallet) =
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
  self.assetsModel.addAssetToList("Ethereum", symbol, fmt"{eth_value:.6}", "$" & fmt"{usd_balance:.6}", fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
