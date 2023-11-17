import NimQml, Tables, json, sequtils, chronicles, strutils, algorithm

import web3/ethtypes
from web3/conversions import `$`
import backend/backend as backend

import app_service/service/network/service as network_service
import app_service/service/wallet_account/dto/account_dto

import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import app_service/common/cache
import ../../../constants as main_constants
import ./dto, ./service_items

export dto, service_items

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
const SIGNAL_TOKENS_LIST_UPDATED* = "tokensListUpdated"
const SIGNAL_TOKENS_LIST_ABOUT_TO_BE_UPDATED* = "tokensListAboutToBeUpdated"

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

    # TODO: remove these once community usage of this service is removed etc...
    tokens: Table[int, seq[TokenDto]]
    tokenList: seq[TokenDto]
    tokensToAddressesMap: Table[string, TokenData]

    priceCache: TimedCache[float64]

    sourcesOfTokensList: seq[SupportedSourcesItem]
    flatTokenList: seq[TokenItem]
    tokenBySymbolList: seq[TokenBySymbolItem]
    # TODO: Table[symbol, TokenDetails] fetched from cryptocompare
    # will be done under https://github.com/status-im/status-desktop/issues/12668
    tokenDetailsList: Table[string, TokenDetails]


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

    result.sourcesOfTokensList = @[]
    result.flatTokenList = @[]
    result.tokenBySymbolList = @[]
    result.tokenDetailsList = initTable[string, TokenDetails]()

  # Callback to process the response of getSupportedTokensList call
  proc supportedTokensListRetrieved(self: Service, response: string) {.slot.} =
    # this is emited so that the models can know that the seq it depends on has been updated
    defer: self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())

    let parsedJson = response.parseJson
    var errorString: string
    var supportedTokensJson, tokensResult: JsonNode
    discard parsedJson.getProp("supportedTokensJson", supportedTokensJson)
    discard parsedJson.getProp("supportedTokensJson", errorString)
    discard supportedTokensJson.getProp("result", tokensResult)

    if not errorString.isEmptyOrWhitespace:
      raise newException(Exception, "Error getting supported tokens list: " & errorString)
    let sourcesList = if tokensResult.isNil or tokensResult.kind == JNull: @[]
              else: Json.decode($tokensResult, seq[TokenSourceDto], allowUnknownFields = true)

    let supportedNetworkChains = self.networkService.getAllNetworkChainIds()
    var flatTokensList: Table[string, TokenItem] = initTable[string, TokenItem]()
    var tokenBySymbolList: Table[string, TokenBySymbolItem] = initTable[string, TokenBySymbolItem]()

    for s in sourcesList:
      let newSource = SupportedSourcesItem(name: s.name, updatedAt: s.updatedAt, source: s.source, version: s.version, tokensCount: s.tokens.len)
      self.sourcesOfTokensList.add(newSource)

      for token in s.tokens:
        # Remove tokens that are not on list of supported status networks
        if supportedNetworkChains.contains(token.chainID):
          # logic for building flat tokens list
          let unique_key = $token.chainID & token.address
          if flatTokensList.hasKey(unique_key):
            flatTokensList[unique_key].sources.add(s.name)
          else:
            let tokenType = if s.name == "native" : NewTokenType.Native
                            else: NewTokenType.ERC20
            flatTokensList[unique_key] = TokenItem(
              key: unique_key,
              name: token.name,
              symbol: token.symbol,
              sources: @[s.name],
              chainID: token.chainID,
              address: token.address,
              decimals: token.decimals,
              image: "",
              `type`: tokenType,
              communityId: token.communityID)

          # logic for building tokens by symbol list
          # In case the token is not a community token the unique key is symbol
          # In case this is a community token the only param reliably unique is its address
          # as there is always a rare case that a user can create two or more community token
          # with same symbol and cannot be avoided
          let token_by_symbol_key = if token.communityID.isEmptyOrWhitespace: token.symbol
                                    else: token.address
          if tokenBySymbolList.hasKey(token_by_symbol_key):
            if not tokenBySymbolList[token_by_symbol_key].sources.contains(s.name):
              tokenBySymbolList[token_by_symbol_key].sources.add(s.name)
            # this logic is to check if an entry for same chainId as been made already,
            # in that case we simply add it to address per chain
            var addedChains: seq[int] = @[]
            for addressPerChain in tokenBySymbolList[token_by_symbol_key].addressPerChainId:
              addedChains.add(addressPerChain.chainId)
            if not addedChains.contains(token.chainID):
              tokenBySymbolList[token_by_symbol_key].addressPerChainId.add(AddressPerChain(chainId: token.chainID, address: token.address))
          else:
            let tokenType = if s.name == "native": NewTokenType.Native
                            else: NewTokenType.ERC20
            tokenBySymbolList[token_by_symbol_key] = TokenBySymbolItem(
              key: token_by_symbol_key,
              name: token.name,
              symbol: token.symbol,
              sources: @[s.name],
              addressPerChainId: @[AddressPerChain(chainId: token.chainID, address: token.address)],
              decimals: token.decimals,
              image: "",
              `type`: tokenType,
              communityId: token.communityID)

    self.flatTokenList = toSeq(flatTokensList.values)
    self.flatTokenList.sort(cmpTokenItem)
    self.tokenBySymbolList = toSeq(tokenBySymbolList.values)
    self.tokenBySymbolList.sort(cmpTokenBySymbolItem)

  proc getSupportedTokensList(self: Service) =
    # this is emited so that the models can know that an update is about to happen
    self.events.emit(SIGNAL_TOKENS_LIST_ABOUT_TO_BE_UPDATED, Args())
    let arg = GetTokenListTaskArg(
      tptr: cast[ByteAddress](getSupportedTokenList),
      vptr: cast[ByteAddress](self.vptr),
      slot: "supportedTokensListRetrieved",
    )
    self.threadpool.start(arg)

  # TODO: Remove after https://github.com/status-im/status-desktop/issues/12513
  proc loadData*(self: Service) =
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
        let default_tokens = Json.decode($responseTokens.result, seq[TokenDto], allowUnknownFields = true)
        self.tokens[network.chainId] = default_tokens.filter(
          proc(x: TokenDto): bool = x.chainId == network.chainId
        )

        let nativeToken = newTokenDto(
          address = "0x0000000000000000000000000000000000000000",
          name = network.nativeCurrencyName,
          symbol = network.nativeCurrencySymbol,
          decimals = network.nativeCurrencyDecimals,
          chainId = network.chainId,
          communityID = ""
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
    if(not main_constants.WALLET_ENABLED):
      return
    self.loadData()
    self.getSupportedTokensList()
    # ToDo: on self.events.on(SignalType.Message.event) do(e: Args):
    # update and populate internal list and then emit signal

  proc getSourcesOfTokensList*(self: Service): var seq[SupportedSourcesItem] =
    return self.sourcesOfTokensList

  proc getFlatTokensList*(self: Service): var seq[TokenItem] =
    return self.flatTokenList

  proc getTokenBySymbolList*(self: Service): var seq[TokenBySymbolItem] =
    return self.tokenBySymbolList

  # TODO: Remove after https://github.com/status-im/status-desktop/issues/12513
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

  # TODO: Shouldnt be needed after accounts assets are restructured
  proc findTokenByAddress*(self: Service, networkChainId: int, address: string): TokenDto =
    if not self.tokens.hasKey(networkChainId):
      return
    for token in self.tokens[networkChainId]:
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
        if token.address == $hexAddressValue:
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

  # TODO: The below two APIS are not linked with generic tokens list but with assets per account and should perhaps be moved to
  # wallet_account->token_service.nim and clean up rest of the code too. Callback to process the response of
  # fetchHistoricalBalanceForTokenAsJson call
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
      error "failed to find a network with the symbol", tokenSymbol
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
