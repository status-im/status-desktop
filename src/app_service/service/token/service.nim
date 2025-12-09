import nimqml, tables, json, sequtils, chronicles, strutils, algorithm, sugar

import web3/eth_api_types
import backend/backend as backend

import app_service/service/network/service as network_service
import app_service/service/settings/service as settings_service

import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import app/core/signals/types
import app_service/common/cache
import app_service/common/wallet_constants
import ./dto, ./service_items, ./utils
import json_serialization

export dto, service_items

logScope:
  topics = "token-service"

include async_tasks

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

    sourcesOfTokensList: seq[SupportedSourcesItem]
    flatTokenList: seq[TokenItem]
    tokenBySymbolList: seq[TokenBySymbolItem]
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

  proc delete*(self: Service)
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

    result.sourcesOfTokensList = @[]
    result.flatTokenList = @[]
    result.tokenBySymbolList = @[]
    result.tokenDetailsTable = initTable[string, TokenDetailsItem]()
    result.tokenMarketValuesTable = initTable[string, TokenMarketValuesItem]()
    result.tokenPriceTable = initTable[string, float64]()
    result.tokenPreferencesTable = initTable[string, TokenPreferencesItem]()
    result.tokensDetailsLoading = true
    result.tokensPricesLoading = true
    result.tokensMarketDetailsLoading = true
    result.hasMarketDetailsCache = false
    result.hasPriceValuesCache = false

  proc fetchTokensMarketValues(self: Service, symbols: seq[string]) =
    self.tokensMarketDetailsLoading = true
    defer: self.events.emit(SIGNAL_TOKENS_MARKET_VALUES_ABOUT_TO_BE_UPDATED, Args())
    let arg = FetchTokensMarketValuesTaskArg(
      tptr: fetchTokensMarketValuesTask,
      vptr: cast[uint](self.vptr),
      slot: "tokensMarketValuesRetrieved",
      symbols: symbols,
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
        let marketValuesDto = Json.decode($marketValuesObj, dto.TokenMarketValuesDto, allowUnknownFields = true)
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

  proc fetchTokensDetails(self: Service, symbols: seq[string]) =
    self.tokensDetailsLoading = true
    let arg = FetchTokensDetailsTaskArg(
      tptr: fetchTokensDetailsTask,
      vptr: cast[uint](self.vptr),
      slot: "tokensDetailsRetrieved",
      symbols: symbols
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
        let tokenDetailsDto = Json.decode($tokenDetailsObj, dto.TokenDetailsDto, allowUnknownFields = true)
        self.tokenDetailsTable[symbol] = TokenDetailsItem(
          description: tokenDetailsDto.description,
          assetWebsiteUrl: tokenDetailsDto.assetWebsiteUrl)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc getTokenListUpdatedAt*(self: Service): int64 =
    return self.tokenListUpdatedAt

  proc fetchTokensPrices(self: Service, symbols: seq[string]) =
    self.tokensPricesLoading = true
    defer: self.events.emit(SIGNAL_TOKENS_PRICES_ABOUT_TO_BE_UPDATED, Args())
    let arg = FetchTokensPricesTaskArg(
      tptr: fetchTokensPricesTask,
      vptr: cast[uint](self.vptr),
      slot: "tokensPricesRetrieved",
      symbols: symbols,
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
    let sourceName = "custom"
    let tokenType = TokenType.ERC20

    var updated = false
    let unique_key = token.flatModelKey()
    if not any(self.flatTokenList, proc (x: TokenItem): bool = x.key == unique_key):
      self.flatTokenList.add(TokenItem(
        key: unique_key,
        name: token.name,
        symbol: token.symbol,
        sources: @[sourceName],
        chainID: token.chainID,
        address: token.address,
        decimals: token.decimals,
        image: token.image,
        `type`: tokenType,
        communityId: token.communityID))
      self.flatTokenList.sort(cmpTokenItem)
      updated = true

    let token_by_symbol_key = token.bySymbolModelKey()
    if not any(self.tokenBySymbolList, proc (x: TokenBySymbolItem): bool = x.key == token_by_symbol_key):
      self.tokenBySymbolList.add(TokenBySymbolItem(
          key: token_by_symbol_key,
          name: token.name,
          symbol: token.symbol,
          sources: @[sourceName],
          addressPerChainId: @[AddressPerChain(chainId: token.chainID, address: token.address)],
          decimals: token.decimals,
          image: token.image,
          `type`: tokenType,
          communityId: token.communityID))
      self.tokenBySymbolList.sort(cmpTokenBySymbolItem)
      updated = true

    if updated:
      self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())

  # Callback to process the response of getSupportedTokensList call
  proc supportedTokensListRetrieved(self: Service, response: string) {.slot.} =
    # this is emited so that the models can know that the seq it depends on has been updated
    defer:
      self.fetchTokenPreferences()
      self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())
    try:
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
      # Workaround for https://github.com/status-im/status-app/issues/17398
      let tokenResultStr = $tokensResult
      let tokenList =  Json.decode(tokenResultStr, TokenListDto, allowUnknownFields = true)

      self.tokenListUpdatedAt = tokenList.updatedAt

      let supportedNetworkChains = self.networkService.getFlatNetworks().map(n => n.chainId)
      var flatTokensList: Table[string, TokenItem] = initTable[string, TokenItem]()
      var tokenBySymbolList: Table[string, TokenBySymbolItem] = initTable[string, TokenBySymbolItem]()
      var tokenSymbols: seq[string] = @[]

      self.sourcesOfTokensList = @[]
      for s in tokenList.data:
        let newSource = SupportedSourcesItem(
          name: s.name,
          updatedAt: s.lastUpdateTimestamp,
          source: s.source,
          version: s.version,
          tokensCount: s.tokens.len
        )
        self.sourcesOfTokensList.add(newSource)

        for token in s.tokens:
          # Remove tokens that are not on list of supported status networks
          if supportedNetworkChains.contains(token.chainID):
            # logic for building flat tokens list
            let unique_key = token.flatModelKey()
            if flatTokensList.hasKey(unique_key):
              flatTokensList[unique_key].sources.add(s.name)
            else:
              let tokenType = if s.name == "native" : TokenType.Native
                              else: TokenType.ERC20
              flatTokensList[unique_key] = TokenItem(
                key: unique_key,
                name: token.name,
                symbol: token.symbol,
                sources: @[s.name],
                chainID: token.chainID,
                address: token.address,
                decimals: token.decimals,
                image: token.image,
                `type`: tokenType,
                communityId: token.communityData.id)

            # logic for building tokens by symbol list
            # In case the token is not a community token the unique key is symbol
            # In case this is a community token the only param reliably unique is its address
            # as there is always a rare case that a user can create two or more community token
            # with same symbol and cannot be avoided
            let token_by_symbol_key = token.bySymbolModelKey()
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
              let tokenType = if s.name == "native": TokenType.Native
                              else: TokenType.ERC20
              tokenBySymbolList[token_by_symbol_key] = TokenBySymbolItem(
                key: token_by_symbol_key,
                name: token.name,
                symbol: token.symbol,
                sources: @[s.name],
                addressPerChainId: @[AddressPerChain(chainId: token.chainID, address: token.address)],
                decimals: token.decimals,
                image: token.image,
                `type`: tokenType,
                communityId: token.communityData.id)
              if token.communityData.id.isEmptyOrWhitespace:
                tokenSymbols.add(token.symbol)

      self.fetchTokensMarketValues(tokenSymbols)
      self.fetchTokensDetails(tokenSymbols)
      self.fetchTokensPrices(tokenSymbols)
      self.flatTokenList = toSeq(flatTokensList.values)
      self.flatTokenList.sort(cmpTokenItem)
      self.tokenBySymbolList = toSeq(tokenBySymbolList.values)
      self.tokenBySymbolList.sort(cmpTokenBySymbolItem)
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

  proc getSourcesOfTokensList*(self: Service): var seq[SupportedSourcesItem] =
    return self.sourcesOfTokensList

  proc getFlatTokensList*(self: Service): var seq[TokenItem] =
    return self.flatTokenList

  proc getTokenBySymbolList*(self: Service): var seq[TokenBySymbolItem] =
    return self.tokenBySymbolList

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
    let symbols = self.tokenBySymbolList.map(a => a.symbol)
    if symbols.len > 0:
      self.fetchTokensMarketValues(symbols)
      self.fetchTokensPrices(symbols)

  proc getTokenByFlatTokensKey*(self: Service, key: string): TokenItem =
    for t in self.flatTokenList:
      if t.key == key:
        return t
    return

  proc getTokenMarketPrice*(self: Service, key: string): float64 =
    let token = self.flatTokenList.filter(t => t.key == key)
    var symbol: string = ""
    for t in token:
      symbol = t.symbol
    if not self.tokenPriceTable.hasKey(symbol):
      return 0
    else:
      return self.tokenPriceTable[symbol]

  proc getTokenBySymbolByTokensKey*(self: Service, key: string): TokenBySymbolItem =
    for token in self.tokenBySymbolList:
      if token.key == key:
        return token
    return nil

  proc getTokenBySymbolByContractAddr(self: Service, contractAddr: string): TokenBySymbolItem =
    for token in self.tokenBySymbolList:
      for addrPerChainId in token.addressPerChainId:
        if addrPerChainId.address.toLower() == contractAddr.toLower():
          return token
    return nil

  proc getStatusTokenKey*(self: Service): string =
    var token: TokenBySymbolItem
    if self.settingsService.areTestNetworksEnabled():
      token = self.getTokenBySymbolByContractAddr(STT_CONTRACT_ADDRESS_SEPOLIA)
    else:
      token = self.getTokenBySymbolByContractAddr(SNT_CONTRACT_ADDRESS)
    if token != nil:
      return token.key
    else:
        return ""

  # TODO: needed in token permission right now, and activity controller which needs
  # to consider that token symbol may not be unique
  # https://github.com/status-im/status-app/issues/13505
  proc findTokenBySymbol*(self: Service, symbol: string): TokenBySymbolItem =
    for token in self.tokenBySymbolList:
      if token.symbol == symbol:
        return token
    return nil

  # TODO: remove this call once the activty filter mechanism uses tokenKeys instead of the token
  # symbol as we may have two tokens with the same symbol in the future. Only tokensKey will be unqiue
  # https://github.com/status-im/status-app/issues/13505
  proc findTokenBySymbolAndChainId*(self: Service, symbol: string, chainId: int): TokenBySymbolItem =
    for token in self.tokenBySymbolList:
      if token.symbol == symbol:
        for addrPerChainId in token.addressPerChainId:
          if addrPerChainId.chainId == chainId:
            return token
    return nil

  # TODO: Perhaps will be removed after transactions in chat is refactored
  proc findTokenByAddress*(self: Service, networkChainId: int, address: string): TokenBySymbolItem =
    for token in self.tokenBySymbolList:
      for addrPerChainId in token.addressPerChainId:
        if addrPerChainId.chainId == networkChainId and addrPerChainId.address == address:
          return token
    return nil

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
      tptr: getTokenHistoricalDataTask,
      vptr: cast[uint](self.vptr),
      slot: "tokenHistoricalDataResolved",
      symbol: symbol,
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

  proc delete*(self: Service) =
    self.QObject.delete

