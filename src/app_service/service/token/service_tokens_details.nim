# if tokensKeys is empty, market values for all tokens will be fetched
proc fetchTokensMarketValues(self: Service, tokensKeys: seq[string] = @[]) =
  self.tokensMarketDetailsLoading = true
  defer: self.events.emit(SIGNAL_TOKENS_MARKET_VALUES_ABOUT_TO_BE_UPDATED, Args())
  let arg = FetchTokensMarketValuesTaskArg(
    tptr: fetchTokensMarketValuesTask,
    vptr: cast[uint](self.vptr),
    slot: "tokensMarketValuesRetrieved",
    tokensKeys: tokensKeys,
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

    for (tokenKey, marketValuesObj) in tokensResult.pairs:
      let marketValuesDto = Json.decode($marketValuesObj, TokenMarketValuesDto, allowUnknownFields = true)
      self.tokenMarketValuesTable[tokenKey] = TokenMarketValuesItem(
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

# if tokensKeys is empty, details for all tokens will be fetched
proc fetchTokensDetails(self: Service, tokensKeys: seq[string] = @[]) =
  self.tokensDetailsLoading = true
  let arg = FetchTokensDetailsTaskArg(
    tptr: fetchTokensDetailsTask,
    vptr: cast[uint](self.vptr),
    slot: "tokensDetailsRetrieved",
    tokensKeys: tokensKeys
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

    for (tokenKey, tokenDetailsObj) in tokensResult.pairs:
      let tokenDetailsDto = Json.decode($tokenDetailsObj, TokenDetailsDto, allowUnknownFields = true)
      self.tokenDetailsTable[tokenKey] = TokenDetailsItem(
        description: tokenDetailsDto.description,
        assetWebsiteUrl: tokenDetailsDto.assetWebsiteUrl)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription

# if tokensKeys is empty, prices for all tokens will be fetched
proc fetchTokensPrices(self: Service, tokensKeys: seq[string] = @[]) =
  self.tokensPricesLoading = true
  defer: self.events.emit(SIGNAL_TOKENS_PRICES_ABOUT_TO_BE_UPDATED, Args())
  let arg = FetchTokensPricesTaskArg(
    tptr: fetchTokensPricesTask,
    vptr: cast[uint](self.vptr),
    slot: "tokensPricesRetrieved",
    tokensKeys: tokensKeys,
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

    for (tokenKey, prices) in tokensResult.pairs:
      for (currency, price) in prices.pairs:
        if cmpIgnoreCase(self.getCurrency(), currency) == 0:
          self.tokenPriceTable[tokenKey] = price.getFloat
    self.hasPriceValuesCache = true
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription

# History Data
proc tokenHistoricalDataResolved*(self: Service, response: string) {.slot.} =
  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    info "prepared tokens are not a json object"
    return

  self.events.emit(SIGNAL_TOKEN_HISTORICAL_DATA_LOADED, TokenHistoricalDataArgs(
    result: response
  ))

proc getHistoricalDataForToken*(self: Service, tokenKey: string, currency: string, range: int) =
  let arg = GetTokenHistoricalDataTaskArg(
    tptr: getTokenHistoricalDataTask,
    vptr: cast[uint](self.vptr),
    slot: "tokenHistoricalDataResolved",
    tokenKey: tokenKey,
    currency: currency,
    range: range
  )
  self.threadpool.start(arg)