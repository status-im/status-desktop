import tables, strformat, strutils, stint, httpclient, json
import ../libstatus/wallet as status_wallet
import ../libstatus/tokens as status_tokens
import account
import token_list

type BalanceManager* = ref object
  pricePairs: Table[string, string]
  tokenBalances: Table[string, string]

proc newBalanceManager*(): BalanceManager =
  result = BalanceManager()
  result.pricePairs = initTable[string, string]()
  result.tokenBalances = initTable[string, string]()

var balanceManager = newBalanceManager()

proc getPrice(crypto: string, fiat: string): string =
  try:
    if balanceManager.pricePairs.hasKey(fiat):
      return balanceManager.pricePairs[fiat]
    var url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
    echo url
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    echo $response.body
    result = $parseJson(response.body)[fiat.toUpper]
    balanceManager.pricePairs[fiat] = result
  except Exception as e:
    echo "error getting price"
    echo e.msg

proc getEthBalance(address: string): string =
  var balance = status_wallet.getBalance(address)
  result = status_wallet.hex2Eth(balance)
  balanceManager.tokenBalances["ETH"] = result

proc getBalance*(symbol: string, accountAddress: string): string =
  if balanceManager.tokenBalances.hasKey(symbol):
    return balanceManager.tokenBalances[symbol]

  if symbol == "ETH":
    return getEthBalance(accountAddress)
  var token: AssetConfig = getTokenConfig(symbol)
  result = $status_tokens.getTokenBalance(token.address, accountAddress)
  balanceManager.tokenBalances[symbol] = result

proc getFiatValue*(crypto_balance: string, crypto_symbol: string, fiat_symbol: string): float =
  if crypto_balance == "0.0": return 0.0
  var fiat_crypto_price = getPrice(crypto_symbol, fiat_symbol)
  parseFloat(crypto_balance) * parseFloat(fiat_crypto_price)

proc updateBalance*(asset: Asset, currency: string) =
  var token_balance = getBalance(asset.symbol, "0xf977814e90da44bfa03b6295a0616a897441acec")
  let fiat_balance = getFiatValue(token_balance, asset.symbol, currency)
  asset.value = token_balance
  asset.fiatValue = fmt"{fiat_Balance:.2f} {currency}"

proc updateBalance*(account: Account, currency: string) =
  let eth_balance = getBalance("ETH", account.address)
  let usd_balance = getFiatValue(eth_balance, "ETH", currency)
  var totalAccountBalance = usd_balance
  account.balance = fmt"{totalAccountBalance:.2f} {currency}"
  for asset in account.assetList:
    updateBalance(asset, currency)
