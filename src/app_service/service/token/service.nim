import NimQml, Tables, json, sequtils, chronicles, strutils

import web3/ethtypes
from web3/conversions import `$`
import ../../../backend/backend as backend

import ../network/service as network_service
import ../wallet_account/dto as wallet_account_dto
import ../../../app/global/global_singleton

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../common/cache
import ../../../constants as main_constants
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

type 
  TokenData* = ref object of RootObj
    addresses*: Table[int, string]
    decimals*: int

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    tokens: Table[int, seq[TokenDto]]
    tokenList: seq[TokenDto]
    tokensToAddressesMap: Table[string, TokenData]
    priceCache: TimedCache[float64]

  proc updateCachedTokenPrice(self: Service, crypto: string, fiat: string, price: float64)
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
    result.tokenList = @[]
    result.tokensToAddressesMap = initTable[string, TokenData]()

  proc loadData*(self: Service) =
    if(not main_constants.WALLET_ENABLED):
      return

    try:
      let networks = self.networkService.getNetworks()
    
      for network in networks:
        let network = network # TODO https://github.com/nim-lang/Nim/issues/16740
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

        let nativeToken = newTokenDto(
          name = network.nativeCurrencyName,
          chainId = network.chainId,
          address = Address.fromHex("0x0000000000000000000000000000000000000000"),
          symbol = network.nativeCurrencySymbol,
          decimals = network.nativeCurrencyDecimals,
          hasIcon = false
        )

        if not self.tokensToAddressesMap.hasKey(network.nativeCurrencySymbol):
          self.tokenList.add(nativeToken)
          self.tokensToAddressesMap[nativeToken.symbol] = TokenData(
            addresses: initTable[int, string](),
          )

        if not self.tokensToAddressesMap[nativeToken.symbol].addresses.hasKey(nativeToken.chainId):
          self.tokensToAddressesMap[nativeToken.symbol].addresses[nativeToken.chainId] = $nativeToken.address
          self.tokensToAddressesMap[nativeToken.symbol].decimals = nativeToken.decimals

        for token in default_tokens:
          if not self.tokensToAddressesMap.hasKey(token.symbol):
            self.tokenList.add(token)
            self.tokensToAddressesMap[token.symbol] = TokenData(
              addresses: initTable[int, string](),
            )

          if not self.tokensToAddressesMap[token.symbol].addresses.hasKey(token.chainId):
            self.tokensToAddressesMap[token.symbol].addresses[token.chainId] = $token.address
            self.tokensToAddressesMap[token.symbol].decimals = token.decimals

    except Exception as e:
      error "Tokens init error", errDesription = e.msg

  proc init*(self: Service) =
    self.loadData()
    
  proc getTokenList*(self: Service): seq[TokenDto] = 
    return self.tokenList

  proc hasContractAddressesForToken*(self: Service, symbol: string): bool =
    return self.tokensToAddressesMap.hasKey(symbol)

  proc getTokenDecimals*(self: Service, symbol: string): int =
    if self.hasContractAddressesForToken(symbol):
      return self.tokensToAddressesMap[symbol].decimals

  proc getContractAddressesForToken*(self: Service, symbol: string): Table[int, string] =
    if self.hasContractAddressesForToken(symbol):
      return self.tokensToAddressesMap[symbol].addresses

  proc findTokenBySymbol*(self: Service, chainId: int, symbol: string): TokenDto =
    if not self.tokens.hasKey(chainId):
      return
    for token in self.tokens[chainId]:
      if token.symbol == symbol:
        return token

  proc findTokenByAddress*(self: Service, network: NetworkDto, address: Address): TokenDto =
    if not self.tokens.hasKey(network.chainId):
      return
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

  proc getTokenPriceCacheKey(crypto: string, fiat: string) : string =
    return crypto & fiat

  proc getCryptoKeyAndFactor(crypto: string) : (string, float64) =
    return CRYPTO_SUB_UNITS_TO_FACTOR.getOrDefault(crypto, (crypto, 1.0))

  proc jsonToPricesMap(node: JsonNode) : Table[string, Table[string, float64]] =
    result = initTable[string, Table[string, float64]]()

    for (symbol, pricePerCurrency) in node.pairs:
      result[symbol] = initTable[string, float64]()
      for (currency, price) in pricePerCurrency.pairs:
        result[symbol][currency] = price.getFloat

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
    let (cryptoKey, factor) = getCryptoKeyAndFactor(crypto)

    let cacheKey = getTokenPriceCacheKey(cryptoKey, fiat)
    if self.priceCache.isCached(cacheKey):
      return self.priceCache.get(cacheKey) * factor

    try:
      let response = backend.fetchPrices(@[cryptoKey], @[fiat])
      let prices = jsonToPricesMap(response.result)
      if not prices.hasKey(cryptoKey) or not prices[cryptoKey].hasKey(fiat):
        return 0.0
      self.updateCachedTokenPrice(cryptoKey, fiat, prices[cryptoKey][fiat])
      return prices[cryptoKey][fiat] * factor
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

  # Callback to process the response of fetchHistoricalBalanceForTokenAsJson call
  proc tokenBalanceHistoryDataResolved*(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    if (responseObj.kind != JObject):
      warn "blance history response is not a json object"
      return

    self.events.emit(SIGNAL_BALANCE_HISTORY_DATA_READY, TokenBalanceHistoryDataArgs(
      result: response
    ))

  proc fetchHistoricalBalanceForTokenAsJson*(self: Service, address: string, tokenSymbol: string, currencySymbol: string, timeInterval: BalanceHistoryTimeInterval) =
    # create an empty list of chain ids
    var chainIds: seq[int] = @[]
    let networks = self.networkService.getNetworks()
    for network in networks:
      if network.enabled:
        if network.nativeCurrencySymbol == tokenSymbol:
          chainIds.add(network.chainId)
        else:
          if not self.tokens.hasKey(network.chainId):
            continue
          for token in self.tokens[network.chainId]:
            if token.symbol == tokenSymbol:
              chainIds.add(network.chainId)

    if chainIds.len == 0:
      error "faild to find a network with the symbol", tokenSymbol
      return

    let arg = GetTokenBalanceHistoryDataTaskArg(
      tptr: cast[ByteAddress](getTokenBalanceHistoryDataTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "tokenBalanceHistoryDataResolved",
      chainIds: chainIds,
      address: address,
      tokenSymbol: tokenSymbol,
      currencySymbol: currencySymbol,
      timeInterval: timeInterval
    )
    self.threadpool.start(arg)
    return
