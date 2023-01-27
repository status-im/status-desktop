import NimQml, Tables, json, sequtils, chronicles, strformat, strutils

from sugar import `=>`
import web3/ethtypes
from web3/conversions import `$`
import ../../../backend/backend as backend

import ../network/service as network_service
import ../wallet_account/dto as wallet_account_dto
import ../../../app/global/global_singleton

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../common/cache
import ./dto

export dto

logScope:
  topics = "token-service"

include async_tasks

const ETHEREUM_SYMBOL = "ETH"
const CRYPTO_SUB_UNITS_TO_FACTOR = {
  "WEI": (ETHEREUM_SYMBOL, 1e-18),
  "KWEI": (ETHEREUM_SYMBOL, 1e-15),
  "MWEI": (ETHEREUM_SYMBOL, 1e-12),
  "GWEI": (ETHEREUM_SYMBOL, 1e-9),
}.toTable()

# Signals which may be emitted by this service:
const SIGNAL_TOKEN_HISTORICAL_DATA_LOADED* = "tokenHistoricalDataLoaded"
const SIGNAL_BALANCE_HISTORY_DATA_READY* = "tokenBalanceHistoryDataReady"

type
  TokenHistoricalDataArgs* = ref object of Args
    result*: string

type
  TokenBalanceHistoryDataArgs* = ref object of Args
    result*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    tokens: Table[int, seq[TokenDto]]
    priceCache: TimedCache[float64]

  proc updateCachedTokenPrice(self: Service, crypto: string, fiat: string, price: float64)
  proc initTokenPrices(self: Service, prices: Table[string, Table[string, float64]])
  proc jsonToPricesMap(node: JsonNode): Table[string, Table[string, float64]] 

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService
    result.tokens = initTable[int, seq[TokenDto]]()
    result.priceCache = newTimedCache[float64]()

  proc init*(self: Service) =
    try:
      let response = backend.getCachedPrices()
      let prices = jsonToPricesMap(response.result)
      self.initTokenPrices(prices)
    except Exception as e:
      error "Cached prices init error", errDesription = e.msg

    try:
      let networks = self.networkService.getNetworks()
    
      for network in networks:
        var found = false
        for chainId in self.tokens.keys:
          if chainId == network.chainId:
            found = true
            break

        if found:
          continue
        
        let responseTokens = backend.getTokens(network.chainId)
        let default_tokens = map(
          responseTokens.result.getElems(), 
          proc(x: JsonNode): TokenDto = x.toTokenDto(network.enabled, hasIcon=true, isCustom=false)
        )

        self.tokens[network.chainId] = default_tokens.filter(
          proc(x: TokenDto): bool = x.chainId == network.chainId
        )
    except Exception as e:
      error "Tokens init error", errDesription = e.msg

  proc findTokenBySymbol*(self: Service, network: NetworkDto, symbol: string): TokenDto =
    try:
      for token in self.tokens[network.chainId]:
        if token.symbol == symbol:
          return token
    except Exception as e:
      error "Error finding token by symbol", msg = e.msg
    
  proc findTokenByAddress*(self: Service, network: NetworkDto, address: Address): TokenDto =
    for token in self.tokens[network.chainId]:
      if token.address == address:
        return token

  proc findTokenSymbolByAddress*(self: Service, address: string): string =
    if address.isEmptyOrWhitespace:
      return ""

    var hexAddressValue: Address
    try:
      hexAddressValue = fromHex(Address, address)
    except Exception as e:
      return ""

    for _, tokens in self.tokens:
      for token in tokens:
        if token.address == hexAddressValue:
          return token.symbol
    return ""

# Token
  proc renameSymbol(symbol: string) : string =
    return toUpperAscii(symbol)

  proc getTokenPriceCacheKey(crypto: string, fiat: string) : string =
    return renameSymbol(crypto) & renameSymbol(fiat)

  proc getCryptoKeyAndFactor(crypto: string) : (string, float64) =
    let cryptoKey = renameSymbol(crypto)
    return CRYPTO_SUB_UNITS_TO_FACTOR.getOrDefault(cryptoKey, (cryptoKey, 1.0))

  proc jsonToPricesMap(node: JsonNode) : Table[string, Table[string, float64]] =
    result = initTable[string, Table[string, float64]]()

    for (symbol, pricePerCurrency) in node.pairs:
      result[symbol] = initTable[string, float64]()
      for (currency, price) in pricePerCurrency.pairs:
        result[symbol][currency] = price.getFloat

  proc initTokenPrices(self: Service, prices: Table[string, Table[string, float64]]) =
    var cacheTable: Table[string, float64]
    for token, pricesPerCurrency in prices:
      for currency, price in pricesPerCurrency:
        let cacheKey = getTokenPriceCacheKey(token, currency)
        cacheTable[cacheKey] = price
    self.priceCache.init(cacheTable)

  proc updateTokenPrices*(self: Service, tokens: seq[WalletTokenDto]) =
    # Use data fetched by walletAccountService to update local price cache
    for token in tokens:
      for currency, marketValues in token.marketValuesPerCurrency:
        self.updateCachedTokenPrice(token.symbol, currency, marketValues.price)

  proc isCachedTokenPriceRecent*(self: Service, crypto: string, fiat: string): bool =
    let (cryptoKey, _) = getCryptoKeyAndFactor(crypto)
    let cacheKey = getTokenPriceCacheKey(cryptoKey, fiat)
    return self.priceCache.isCached(cacheKey)

  proc getTokenPrice*(self: Service, crypto: string, fiat: string): float64 =
    let fiatKey = renameSymbol(fiat)
    let (cryptoKey, factor) = getCryptoKeyAndFactor(crypto)

    let cacheKey = getTokenPriceCacheKey(cryptoKey, fiatKey)
    if self.priceCache.isCached(cacheKey):
      return self.priceCache.get(cacheKey) * factor
    var prices = initTable[string, Table[string, float]]()

    try:
      let response = backend.fetchPrices(@[cryptoKey], @[fiatKey])
      let prices = jsonToPricesMap(response.result)

      self.updateCachedTokenPrice(cryptoKey, fiatKey, prices[cryptoKey][fiatKey])
      return prices[cryptoKey][fiatKey] * factor
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return 0.0
  
  proc getCachedTokenPrice*(self: Service, crypto: string, fiat: string, fetchIfNotPresent: bool = false): float64 =
    let (cryptoKey, factor) = getCryptoKeyAndFactor(crypto)

    let cacheKey = getTokenPriceCacheKey(cryptoKey, fiat)
    if self.priceCache.hasKey(cacheKey):
      return self.priceCache.get(cacheKey) * factor
    elif fetchIfNotPresent:
      return self.getTokenPrice(crypto, fiat)
    else:
      return 0.0

  proc updateCachedTokenPrice(self: Service, crypto: string, fiat: string, price: float64) =
    let cacheKey = getTokenPriceCacheKey(crypto, fiat)
    self.priceCache.set(cacheKey, price)
  
  proc getTokenPegSymbol*(self: Service, symbol: string): string = 
    for _, tokens in self.tokens:
      for token in tokens:
        if token.symbol == symbol:
          return token.pegSymbol
    
    return ""

# History Data
  proc tokenHistoricalDataResolved*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "prepared tokens are not a json object"
      return

    self.events.emit(SIGNAL_TOKEN_HISTORICAL_DATA_LOADED, TokenHistoricalDataArgs(
      result: response
    ))

  proc getHistoricalDataForToken*(self: Service, symbol: string, currency: string, range: int) =
    let arg = GetTokenHistoricalDataTaskArg(
      tptr: cast[ByteAddress](getTokenHistoricalDataTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "tokenHistoricalDataResolved",
      symbol: symbol,
      currency: currency,
      range: range
    )
    self.threadpool.start(arg)

# Historical Balance
  proc tokenBalanceHistoryDataResolved*(self: Service, response: string) {.slot.} =
    # TODO
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      info "blance history response is not a json object"
      return

    self.events.emit(SIGNAL_BALANCE_HISTORY_DATA_READY, TokenBalanceHistoryDataArgs(
      result: response
    ))

  proc fetchHistoricalBalanceForTokenAsJson*(self: Service, address: string, symbol: string, timeInterval: BalanceHistoryTimeInterval) =
    let networks = self.networkService.getNetworks()
    for network in networks:
      if network.enabled and network.nativeCurrencySymbol == symbol:
        let arg = GetTokenBalanceHistoryDataTaskArg(
          tptr: cast[ByteAddress](getTokenBalanceHistoryDataTask),
          vptr: cast[ByteAddress](self.vptr),
          slot: "tokenBalanceHistoryDataResolved",
          chainId: network.chainId,
          address: address,
          symbol: symbol,
          timeInterval: timeInterval
        )
        self.threadpool.start(arg)
        return
    error "faild to find a network with the symbol", symbol