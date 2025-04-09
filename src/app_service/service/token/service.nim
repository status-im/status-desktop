import NimQml, Tables, sets, json, sequtils, chronicles, strutils, algorithm, sugar

import web3/ethtypes
import backend/backend as backend

import app_service/common/wallet_constants
import app_service/service/network/service as network_service
import app_service/service/settings/service as settings_service

import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import app/core/signals/types
import app_service/common/cache
import types/imports as token_types

export token_types

logScope:
  topics = "token-service"

include async_tasks

const
  NativeTokensListName = "native"
  CustomTokensListName = "custom"

const ETHEREUM_SYMBOL = "ETH"
const CRYPTO_SUB_UNITS_TO_FACTOR = {
  "WEI": (ETHEREUM_SYMBOL, 1e-18),
  "KWEI": (ETHEREUM_SYMBOL, 1e-15),
  "MWEI": (ETHEREUM_SYMBOL, 1e-12),
  "GWEI": (ETHEREUM_SYMBOL, 1e-9),
}.toTable()

# Signals which may be emitted by this service:
const SIGNAL_TOKEN_HISTORICAL_DATA_LOADED* = "tokenHistoricalDataLoaded"
const SIGNAL_TOKENS_LIST_UPDATED* = "tokensListUpdated"
const SIGNAL_TOKENS_DETAILS_ABOUT_TO_BE_UPDATED* = "tokensDetailsAboutToBeUpdated"
const SIGNAL_TOKENS_DETAILS_UPDATED* = "tokensDetailsUpdated"
const SIGNAL_TOKENS_MARKET_VALUES_ABOUT_TO_BE_UPDATED* = "tokensMarketValuesAboutToBeUpdated"
const SIGNAL_TOKENS_PRICES_ABOUT_TO_BE_UPDATED* = "tokensPricesValuesAboutToBeUpdated"
const SIGNAL_TOKENS_MARKET_VALUES_UPDATED* = "tokensMarketValuesUpdated"
const SIGNAL_TOKENS_PRICES_UPDATED* = "tokensPricesValuesUpdated"
const SIGNAL_TOKEN_PREFERENCES_UPDATED* = "tokenPreferencesUpdated"

type
  ResultArgs* = ref object of Args
    success*: bool

type
  TokenHistoricalDataArgs* = ref object of Args
    result*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    settingsService: settings_service.Service

    tokenLists: seq[TokenListItem]
    flatTokens: seq[TokenItem]
    groupedTokens: seq[TokenGroupItem]
    tokenDetailsTable: Table[string, TokenDetailsItem]
    tokenMarketValuesTable: Table[string, TokenMarketValuesItem]
    tokenPriceTable: Table[string, float64]
    tokenPreferencesTable: Table[string, TokenPreferencesItem]
    tokenPreferencesJson: string
    tokensDetailsLoading: bool
    tokensPricesLoading: bool
    tokensMarketDetailsLoading: bool
    hasMarketDetailsCache: bool
    hasPriceValuesCache: bool
    tokenListUpdatedAt: int64

  proc getCurrency*(self: Service): string
  proc rebuildMarketData*(self: Service)
  proc fetchTokenPreferences(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
    settingsService: settings_service.Service
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService
    result.settingsService = settingsService

    result.tokenLists = @[]
    result.flatTokens = @[]
    result.groupedTokens = @[]
    result.tokenDetailsTable = initTable[string, TokenDetailsItem]()
    result.tokenMarketValuesTable = initTable[string, TokenMarketValuesItem]()
    result.tokenPriceTable = initTable[string, float64]()
    result.tokenPreferencesTable = initTable[string, TokenPreferencesItem]()
    result.tokensDetailsLoading = true
    result.tokensPricesLoading = true
    result.tokensMarketDetailsLoading = true
    result.hasMarketDetailsCache = false
    result.hasPriceValuesCache = false

  proc fetchTokensMarketValues(self: Service, groupedTokensKeys: seq[string]) =
    self.tokensMarketDetailsLoading = true
    defer: self.events.emit(SIGNAL_TOKENS_MARKET_VALUES_ABOUT_TO_BE_UPDATED, Args())
    let arg = FetchTokensMarketValuesTaskArg(
      tptr: fetchTokensMarketValuesTask,
      vptr: cast[uint](self.vptr),
      slot: "tokensMarketValuesRetrieved",
      groupedTokensKeys: groupedTokensKeys,
      currency: self.getCurrency()
    )
    self.threadpool.start(arg)

  proc tokensMarketValuesRetrieved(self: Service, response: string) {.slot.} =
    # this is emited so that the models can notify about market values being available
    self.tokensMarketDetailsLoading = false
    defer: self.events.emit(SIGNAL_TOKENS_MARKET_VALUES_UPDATED, Args())
    try:
      let parsedJson = response.parseJson
      var errorString: string
      var tokenMarketValues, tokensResult: JsonNode
      discard parsedJson.getProp("tokenMarketValues", tokenMarketValues)
      discard parsedJson.getProp("error", errorString)
      discard tokenMarketValues.getProp("result", tokensResult)

      if not errorString.isEmptyOrWhitespace:
        raise newException(Exception, "Error getting tokens market values: " & errorString)
      if tokensResult.isNil or tokensResult.kind == JNull:
        return

      for (symbol, marketValuesObj) in tokensResult.pairs:
        let marketValuesDto = Json.decode($marketValuesObj, TokenMarketValuesDto, allowUnknownFields = true)
        self.tokenMarketValuesTable[symbol] = TokenMarketValuesItem(
          marketCap: marketValuesDto.marketCap,
          highDay: marketValuesDto.highDay,
          lowDay: marketValuesDto.lowDay,
          changePctHour: marketValuesDto.changePctHour,
          changePctDay: marketValuesDto.changePctDay,
          changePct24hour: marketValuesDto.changePct24hour,
          change24hour: marketValuesDto.change24hour)
      self.hasMarketDetailsCache = true
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc fetchTokensDetails(self: Service, groupedTokensKeys: seq[string]) =
    self.tokensDetailsLoading = true
    let arg = FetchTokensDetailsTaskArg(
      tptr: fetchTokensDetailsTask,
      vptr: cast[uint](self.vptr),
      slot: "tokensDetailsRetrieved",
      groupedTokensKeys: groupedTokensKeys
    )
    self.threadpool.start(arg)

  proc tokensDetailsRetrieved(self: Service, response: string) {.slot.} =
    self.tokensDetailsLoading = false
    # this is emited so that the models can notify about details being available
    defer: self.events.emit(SIGNAL_TOKENS_DETAILS_UPDATED, Args())
    try:
      let parsedJson = response.parseJson
      var errorString: string
      var tokensDetails, tokensResult: JsonNode
      discard parsedJson.getProp("tokensDetails", tokensDetails)
      discard parsedJson.getProp("error", errorString)
      discard tokensDetails.getProp("result", tokensResult)

      if not errorString.isEmptyOrWhitespace:
        raise newException(Exception, "Error getting tokens details: " & errorString)
      if tokensResult.isNil or tokensResult.kind == JNull:
        return

      for (symbol, tokenDetailsObj) in tokensResult.pairs:
        let tokenDetailsDto = Json.decode($tokenDetailsObj, TokenDetailsDto, allowUnknownFields = true)
        self.tokenDetailsTable[symbol] = TokenDetailsItem(
          description: tokenDetailsDto.description,
          assetWebsiteUrl: tokenDetailsDto.assetWebsiteUrl)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc getTokenListUpdatedAt*(self: Service): int64 =
    return self.tokenListUpdatedAt

  proc fetchTokensPrices(self: Service, groupedTokensKeys: seq[string]) =
    self.tokensPricesLoading = true
    defer: self.events.emit(SIGNAL_TOKENS_PRICES_ABOUT_TO_BE_UPDATED, Args())
    let arg = FetchTokensPricesTaskArg(
      tptr: fetchTokensPricesTask,
      vptr: cast[uint](self.vptr),
      slot: "tokensPricesRetrieved",
      groupedTokensKeys: groupedTokensKeys,
      currencies: @[self.getCurrency()]
    )
    self.threadpool.start(arg)

  proc tokensPricesRetrieved(self: Service, response: string) {.slot.} =
    self.tokensPricesLoading = false
    # this is emited so that the models can notify about prices being available
    defer: self.events.emit(SIGNAL_TOKENS_PRICES_UPDATED, Args())
    try:
      let parsedJson = response.parseJson
      var errorString: string
      var tokensPrices, tokensResult: JsonNode
      discard parsedJson.getProp("tokensPrices", tokensPrices)
      discard parsedJson.getProp("error", errorString)
      discard tokensPrices.getProp("result", tokensResult)

      if not errorString.isEmptyOrWhitespace:
        raise newException(Exception, "Error getting tokens details: " & errorString)
      if tokensResult.isNil or tokensResult.kind == JNull:
        return

      for (symbol, prices) in tokensResult.pairs:
        for (currency, price) in prices.pairs:
          if cmpIgnoreCase(self.getCurrency(), currency) == 0:
            self.tokenPriceTable[symbol] = price.getFloat
      self.hasPriceValuesCache = true
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc addNewCommunityToken*(self: Service, token: TokenDto) =
    let tokenKey = token.tokenKey()
    let tokenToAdd = TokenItem(
      key: tokenKey,
      groupKey: token.tokenGroupKey(),
      name: token.name,
      symbol: token.symbol,
      sources: @[CustomTokensListName],
      chainID: token.chainID,
      address: token.address,
      decimals: token.decimals,
      image: token.image,
      `type`: TokenType.ERC20,
      communityId: token.communityID
    )

    var updated = false
    if not any(self.flatTokens, proc (x: TokenItem): bool = x.key == tokenKey):
      self.flatTokens.add(tokenToAdd)
      self.flatTokens.sort(cmpTokenItem)
      updated = true

    let tokenGroupKey = token.tokenGroupKey()
    if not any(self.groupedTokens, proc (x: TokenGroupItem): bool = x.key == tokenGroupKey):
      self.groupedTokens.add(TokenGroupItem(
          key: tokenGroupKey,
          name: token.name,
          symbol: token.symbol,
          image: token.image,
          `type`: TokenType.ERC20,
          tokens: @[tokenToAdd]
        )
      )
      self.groupedTokens.sort(cmpTokenGroupItem)
      updated = true

    if updated:
      self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())

  proc prepareTokensListsForProcessing(response: string): TokenListDto {.raises: [Exception].} =
    let parsedJson = response.parseJson
    var errorString: string
    var supportedTokensJson, tokensResult: JsonNode
    discard parsedJson.getProp("supportedTokensJson", supportedTokensJson)
    discard parsedJson.getProp("error", errorString)
    discard supportedTokensJson.getProp("result", tokensResult)

    if not errorString.isEmptyOrWhitespace:
      raise newException(Exception, "Error getting supported tokens list: " & errorString)

    if tokensResult.isNil or tokensResult.kind == JNull:
      raise newException(Exception, "Error in response of getting supported tokens list")

    # Create a copy of the tokenResultStr to avoid exceptions in `decode`
    # Workaround for https://github.com/status-im/status-desktop/issues/17398
    let tokenResultStr = $tokensResult
    return Json.decode(tokenResultStr, TokenListDto, allowUnknownFields = true)

  # Callback to process the response of getSupportedTokensList call
  proc supportedTokensListRetrieved(self: Service, response: string) {.slot.} =
    # this is emited so that the models can know that the seq it depends on has been updated
    defer:
      self.fetchTokenPreferences()
      self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())

    try:
      let tokenList = prepareTokensListsForProcessing(response)
      self.tokenListUpdatedAt = tokenList.updatedAt

      var allTokens: Table[string, TokenItem] = initTable[string, TokenItem]()
      var groupedTokens: Table[string, TokenGroupItem] = initTable[string, TokenGroupItem]()

      self.tokenLists = @[]
      for s in tokenList.data:
        var uniqueTokenGroupsPerList: HashSet[string] = initHashSet[string]()
        # token type determined by the source
        let tokenType = if s.name == NativeTokensListName: TokenType.Native else: TokenType.ERC20
        for token in s.tokens:
          let tokenKey = token.tokenKey()
          let tokenGroupKey = token.tokenGroupKey()

          uniqueTokenGroupsPerList.incl(tokenGroupKey)
          if allTokens.hasKey(tokenKey):
            allTokens[tokenKey].sources.add(s.name)
          else:
            allTokens[tokenKey] = TokenItem(
              key: tokenKey,
              groupKey: tokenGroupKey,
              name: token.name,
              symbol: token.symbol,
              sources: @[s.name],
              chainID: token.chainID,
              address: token.address,
              decimals: token.decimals,
              image: token.image,
              `type`: tokenType,
              communityId: token.communityData.id
            )

          let addedTokenItem = allTokens[tokenKey]

          if groupedTokens.hasKey(tokenGroupKey):
            if not groupedTokens[tokenGroupKey].containsTokenItem(addedTokenItem):
              groupedTokens[tokenGroupKey].tokens.add(addedTokenItem)
          else:
            groupedTokens[tokenGroupKey] = TokenGroupItem(
              key: tokenGroupKey,
              name: token.name,
              symbol: token.symbol,
              image: token.image,
              decimals: token.decimals,
              `type`: tokenType,
              tokens: @[addedTokenItem]
            )

        let tokenListItem = TokenListItem(
          name: s.name,
          updatedAt: s.lastUpdateTimestamp,
          source: s.source,
          version: s.version,
          tokensCount: uniqueTokenGroupsPerList.len
        )
        self.tokenLists.add(tokenListItem)

      self.fetchTokensMarketValues(groupedTokens.keys.toSeq())
      self.fetchTokensDetails(groupedTokens.keys.toSeq())
      self.fetchTokensPrices(groupedTokens.keys.toSeq())
      self.flatTokens = toSeq(allTokens.values)
      self.flatTokens.sort(cmpTokenItem)
      self.groupedTokens = toSeq(groupedTokens.values)
      self.groupedTokens.sort(cmpTokenGroupItem)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc getSupportedTokensList*(self: Service) =
    let arg = QObjectTaskArg(
      tptr: getSupportedTokenList,
      vptr: cast[uint](self.vptr),
      slot: "supportedTokensListRetrieved",
    )
    self.threadpool.start(arg)

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-tick-reload":
          self.rebuildMarketData()
    # update and populate internal list and then emit signal when new custom token detected?
    self.events.on(SignalType.WalletTokensListsUpdated.event) do(e:Args):
      self.getSupportedTokensList()

  proc getCurrency*(self: Service): string =
    return self.settingsService.getCurrency()

  proc getTokenLists*(self: Service): seq[TokenListItem] =
    return self.tokenLists

  proc getFlatTokens*(self: Service): seq[TokenItem] =
    return self.flatTokens

  proc getGroupedTokens*(self: Service): seq[TokenGroupItem] =
    return self.groupedTokens

  proc getTokenDetails*(self: Service, symbol: string): TokenDetailsItem =
    if not self.tokenDetailsTable.hasKey(symbol):
      return TokenDetailsItem()
    return self.tokenDetailsTable[symbol]

  proc getMarketValuesBySymbol*(self: Service, symbol: string): TokenMarketValuesItem =
    if not self.tokenMarketValuesTable.hasKey(symbol):
      return TokenMarketValuesItem()
    return self.tokenMarketValuesTable[symbol]

  proc getPriceBySymbol*(self: Service, symbol: string): float64 =
    if not self.tokenPriceTable.hasKey(symbol):
      return 0.0
    return self.tokenPriceTable[symbol]

  proc getTokensDetailsLoading*(self: Service): bool =
    return self.tokensDetailsLoading

  proc getTokensMarketValuesLoading*(self: Service): bool =
    return self.tokensPricesLoading or self.tokensMarketDetailsLoading

  proc getHasMarketValuesCache*(self: Service): bool =
    return self.hasMarketDetailsCache and self.hasPriceValuesCache

  proc rebuildMarketData*(self: Service) =
    let groupedTokensKeys = self.groupedTokens.map(a => a.key)
    if groupedTokensKeys.len > 0:
      self.fetchTokensMarketValues(groupedTokensKeys)
      self.fetchTokensPrices(groupedTokensKeys)

  proc getTokenByTokenKey*(self: Service, key: string): TokenItem =
    for t in self.flatTokens:
      if t.key == key:
        return t
    return

  proc getTokenGroupByGroupedTokensKey*(self: Service, key: string): TokenGroupItem =
    for t in self.groupedTokens:
      if t.key == key:
        return t
    return nil

  proc getTokenGroupByTokenKey*(self: Service, key: string): TokenGroupItem =
    for t in self.groupedTokens:
      if t.containsTokenItemByKey(key):
        return t
    return nil

  proc getTokenMarketPrice*(self: Service, key: string): float64 =
    let token = self.flatTokens.filter(t => t.key == key)
    var symbol: string = ""
    for t in token:
      symbol = t.symbol
    if not self.tokenPriceTable.hasKey(symbol):
      return 0
    else:
      return self.tokenPriceTable[symbol]

  proc getStatusTokenKey*(self: Service): string =
    var tokenDto = TokenDto()
    if self.settingsService.areTestNetworksEnabled():
      tokenDto.address = StatusContractAddressPerChainID[SepoliaChainID]
      tokenDto.chainID = SepoliaChainID
    else:
      tokenDto.address = StatusContractAddressPerChainID[MainnetChainID]
      tokenDto.chainID = MainnetChainID

    let token = self.getTokenByTokenKey(tokenDto.tokenKey())
    if token != nil:
      return token.key
    else:
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

  proc getHistoricalDataForToken*(self: Service, groupedTokenKey: string, currency: string, range: int) =
    let arg = GetTokenHistoricalDataTaskArg(
      tptr: getTokenHistoricalDataTask,
      vptr: cast[uint](self.vptr),
      slot: "tokenHistoricalDataResolved",
      groupedTokenKey: groupedTokenKey,
      currency: currency,
      range: range
    )
    self.threadpool.start(arg)

  # Token Management
  proc fetchTokenPreferences(self: Service) =
    # this is emited so that the models can notify about token preferences being available
    defer: self.events.emit(SIGNAL_TOKEN_PREFERENCES_UPDATED, Args())
    self.tokenPreferencesJson = "[]"
    try:
      let response = backend.getTokenPreferences()
      if not response.error.isNil:
        error "status-go error", procName="fetchTokenPreferences", errCode=response.error.code, errDesription=response.error.message
        return

      if response.result.isNil or response.result.kind != JArray:
        return

      self.tokenPreferencesJson = $response.result
      for preferences in response.result:
        let dto = Json.decode($preferences, TokenPreferencesDto, allowUnknownFields = true)
        self.tokenPreferencesTable[dto.key] = TokenPreferencesItem(
          key: dto.key,
          position: dto.position,
          groupPosition: dto.groupPosition,
          visible: dto.visible,
          communityId: dto.communityId)
    except Exception as e:
      error "error: ", procName="fetchTokenPreferences", errName=e.name, errDesription=e.msg

  proc getTokenPreferences*(self: Service, symbol: string): TokenPreferencesItem =
    if not self.tokenPreferencesTable.hasKey(symbol):
      return TokenPreferencesItem(
        key: symbol,
        position: high(int),
        groupPosition: high(int),
        visible: true,
        communityId: ""
      )
    return self.tokenPreferencesTable[symbol]

  proc getTokenPreferencesJson*(self: Service): string =
    if len(self.tokenPreferencesJson) == 0:
      self.fetchTokenPreferences()
    return self.tokenPreferencesJson

  proc updateTokenPreferences*(self: Service, tokenPreferencesJson: string) =
    try:
      let preferencesJson = parseJson(tokenPreferencesJson)
      var tokenPreferences: seq[TokenPreferencesDto]
      if preferencesJson.kind == JArray:
        for preferences in preferencesJson:
          add(tokenPreferences, Json.decode($preferences, TokenPreferencesDto, allowUnknownFields = false))
      let response = backend.updateTokenPreferences(tokenPreferences)
      if not response.error.isNil:
        raise newException(CatchableError, response.error.message)
      self.fetchTokenPreferences()
    except Exception as e:
      error "error: ", procName="updateTokenPreferences", errName=e.name, errDesription=e.msg

  proc updateTokenPrices*(self: Service, updatedPrices: Table[string, float64]) =
    var anyUpdated = false
    for tokenSymbol, price in updatedPrices:
      if not self.tokenPriceTable.hasKey(tokenSymbol) or self.tokenPriceTable[tokenSymbol] != price:
        anyUpdated = true
        self.tokenPriceTable[tokenSymbol] = price
    if anyUpdated:
      self.events.emit(SIGNAL_TOKENS_PRICES_UPDATED, Args())
