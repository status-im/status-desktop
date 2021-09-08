import strformat, strutils, stint, httpclient, json, chronicles, net
import ../libstatus/wallet as status_wallet
import ../libstatus/tokens as status_tokens
import ../types/[rpc_response]
import ../utils/cache
import account
import options

logScope:
  topics = "balance-manager"

type BalanceManager* = ref object
  pricePairs: CachedValues
  tokenBalances: CachedValues

proc newBalanceManager*(): BalanceManager =
  result = BalanceManager()
  result.pricePairs = newCachedValues()
  result.tokenBalances = newCachedValues()

var balanceManager = newBalanceManager()

proc getPrice(crypto: string, fiat: string): string =
  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext)
  try:
    let url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    result = $parseJson(response.body)[fiat.toUpper]
  except Exception as e:
    error "Error getting price", message = e.msg
    result = "0.0"
  finally:
    client.close()

proc getEthBalance(address: string): string =
  var balance = status_wallet.getBalance(address)
  result = status_wallet.hex2token(balance, 18)

proc getBalance*(symbol: string, accountAddress: string, tokenAddress: string, refreshCache: bool): string =
  let cacheKey = fmt"{symbol}-{accountAddress}-{tokenAddress}"
  if not refreshCache and balanceManager.tokenBalances.isCached(cacheKey):
    return balanceManager.tokenBalances.get(cacheKey)

  if symbol == "ETH":
    let ethBalance = getEthBalance(accountAddress)
    return ethBalance

  result = $status_tokens.getTokenBalance(tokenAddress, accountAddress)
  balanceManager.tokenBalances.cacheValue(cacheKey, result)

proc convertValue*(balance: string, fromCurrency: string, toCurrency: string): float =
  if balance == "0.0": return 0.0
  let cacheKey = fmt"{fromCurrency}-{toCurrency}"
  if balanceManager.pricePairs.isCached(cacheKey):
    return parseFloat(balance) * parseFloat(balanceManager.pricePairs.get(cacheKey))

  var fiat_crypto_price = getPrice(fromCurrency, toCurrency)
  balanceManager.pricePairs.cacheValue(cacheKey, fiat_crypto_price)
  parseFloat(balance) * parseFloat(fiat_crypto_price)

proc updateBalance*(asset: Asset, currency: string, refreshCache: bool): float =
  var token_balance = getBalance(asset.symbol, asset.accountAddress, asset.address, refreshCache)
  let fiat_balance = convertValue(token_balance, asset.symbol, currency)
  asset.value = token_balance
  asset.fiatBalanceDisplay = fmt"{fiat_balance:.2f} {currency}"
  asset.fiatBalance = fmt"{fiat_balance:.2f}"
  return fiat_balance

proc updateBalance*(account: WalletAccount, currency: string, refreshCache: bool = false) =
  try:
    var usd_balance = 0.0
    for asset in account.assetList:
      let assetFiatBalance = updateBalance(asset, currency, refreshCache)
      usd_balance = usd_balance + assetFiatBalance

    account.realFiatBalance = some(usd_balance)
    account.balance = some(fmt"{usd_balance:.2f} {currency}")
  except RpcException:
    error "Error in updateBalance", message = getCurrentExceptionMsg()

proc storeBalances*(account: WalletAccount,  ethBalance = "0", tokenBalance: JsonNode) =
  let ethCacheKey = fmt"ETH-{account.address}-"
  balanceManager.tokenBalances.cacheValue(ethCacheKey, ethBalance)
  for asset in account.assetList:
    if tokenBalance.hasKey(asset.address):
      let cacheKey = fmt"{asset.symbol}-{account.address}-{asset.address}"
      balanceManager.tokenBalances.cacheValue(cacheKey, tokenBalance{asset.address}.getStr())
