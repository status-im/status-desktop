import eventemitter
import json
import strformat
import strutils
import ../status/wallet as status_wallet

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

proc getFiatValue*(self: WalletModel, eth_balance: string, symbol: string, fiat_symbol: string): float =
  # 3. get usd price of 1 eth
  var usd_eth_price = status_wallet.getPrice("ETH", "USD")
  echo(fmt"usd_price: {usd_eth_price}")

  # 4. convert balance to usd
  var usd_balance = parseFloat(eth_balance) * parseFloat(usd_eth_price)
  echo(fmt"balance in usd: {usd_balance}")
  usd_balance
