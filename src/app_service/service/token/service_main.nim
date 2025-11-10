proc rebuildMarketDataInternal(self: Service) =
  self.fetchTokensMarketValues() # TODO: if the only place where we can see these details is account's details page, we should fetch this on demand, no need to have local cache
  self.fetchTokensPrices()

proc rebuildMarketData*(self: Service) =
  self.rebuildMarketDataDebouncer.call()

proc refreshTokens(self: Service) =
  self.allTokenLists = getAllTokenLists()

  self.allTokensByKey.clear()
  self.allGroupsByKey.clear()
  let allTokens = getTokensForActiveNetworksMode()
  for token in allTokens:
    let groupKey = token.groupKey
    self.allTokensByKey[token.key] = token
    if not self.allGroupsByKey.hasKey(groupKey):
      self.allGroupsByKey[groupKey] = TokenGroupItem(
        key: groupKey,
        name: token.name,
        symbol: token.symbol,
        decimals: token.decimals,
        logoUri: token.logoUri
      )
    self.allGroupsByKey[groupKey].addToken(token)
  self.allGroups = toSeq(self.allGroupsByKey.values)

  self.rebuildMarketData()
  self.fetchTokensDetails() # TODO: if the only place where we can see these details is account's details page, we should fetch this on demand, no need to have local cache
  self.fetchTokenPreferences()
  # notify modules
  self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())

proc init*(self: Service) =
  self.rebuildMarketDataDebouncer = debouncer_service.newDebouncer(
    self.threadpool,
    # this is the delay before the first call to the callback, this is an action that doesn't need to be called immediately, but it's pretty expensive in terms of time/performances
    # for example `wallet-tick-reload` event is emitted for every single chain-account pair, and at the app start can be more such signals received from the statusgo side if the balance have changed.
    # Means it the app contains more accounts the likelihood of having more `wallet-tick-reload` signals is higher, so we need to delay the rebuildMarketData call to avoid unnecessary calls.
    delayMs = 1500,
    checkIntervalMs = 500)
  self.rebuildMarketDataDebouncer.registerCall0(callback = proc() = self.rebuildMarketDataInternal())

  self.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    case data.eventType:
      of "wallet-tick-reload":
        self.rebuildMarketData()
  # update and populate internal list and then emit signal when new custom token detected?
  self.events.on(SignalType.WalletTokensListsUpdated.event) do(e:Args):
    self.refreshTokens()

  self.events.on(SIGNAL_NETWORK_MODE_UPDATED) do(e:Args):
    self.refreshTokens()

  self.events.on(SIGNAL_CURRENCY_UPDATED) do(e:Args):
    self.rebuildMarketData()

  self.refreshTokens()

proc getCurrency*(self: Service): string =
  return self.settingsService.getCurrency()

proc getAllTokenGroups*(self: Service): var seq[TokenGroupItem] =
  return self.allGroups

proc getAllTokenLists*(self: Service): var seq[TokenListItem] =
  return self.allTokenLists

proc getAllCommunityTokens*(self: Service): var seq[TokenItem] =
  const communityTokenListId = "community"
  for tl in self.allTokenLists:
    if tl.id == communityTokenListId:
      return tl.tokens

proc getTokenByKey*(self: Service, key: string): TokenItem =
  if key.isEmptyOrWhitespace or not key.toLower.contains("-0x"):
    return nil
  if self.allTokensByKey.hasKey(key):
    return self.allTokensByKey[key]
  let tokens = getTokensByKeys(@[key])
  if tokens.len > 0:
    self.allTokensByKey[key] = tokens[0]
    return self.allTokensByKey[key]
  return nil

proc getTokenByChainAddress*(self: Service, chainId: int, address: string): TokenItem =
  let key = common_utils.createTokenKey(chainId, address)
  return self.getTokenByKey(key)

proc getTokensByGroupKey*(self: Service, groupKey: string): seq[TokenItem] =
  if not self.allGroupsByKey.hasKey(groupKey):
    return @[]
  return self.allGroupsByKey[groupKey].tokens

proc getTokenByGroupKeyAndChainId*(self: Service, groupKey: string, chainId: int): TokenItem =
  let tokens = self.getTokensByGroupKey(groupKey)
  if tokens.len > 0:
    for token in tokens:
      if token.chainId == chainId:
        return token
  return nil

proc tokenAvailableForBridgingViaHop*(self: Service, tokenChainId: int, tokenAddress: string): bool =
  let key = common_utils.createTokenKey(tokenChainId, tokenAddress)
  if self.tokensForBridgingViaHop.hasKey(key):
    return self.tokensForBridgingViaHop[key]
  let available = tokenAvailableForBridgingViaHop(tokenChainId, tokenAddress)
  self.tokensForBridgingViaHop[key] = available
  return available

proc getTokenListUpdatedAt*(self: Service): int64 =
  return self.tokenListUpdatedAt

proc getTokenDetails*(self: Service, tokenKey: string): TokenDetailsItem =
  if not self.tokenDetailsTable.hasKey(tokenKey):
    return TokenDetailsItem()
  return self.tokenDetailsTable[tokenKey]

proc getMarketValuesForToken*(self: Service, tokenKey: string): TokenMarketValuesItem =
  if not self.tokenMarketValuesTable.hasKey(tokenKey):
    return TokenMarketValuesItem()
  return self.tokenMarketValuesTable[tokenKey]

proc getPriceForToken*(self: Service, tokenKey: string): float64 =
  if not self.tokenPriceTable.hasKey(tokenKey):
    return 0.0
  return self.tokenPriceTable[tokenKey]

proc getTokensDetailsLoading*(self: Service): bool =
  return self.tokensDetailsLoading

proc getTokensMarketValuesLoading*(self: Service): bool =
  return self.tokensPricesLoading or self.tokensMarketDetailsLoading

proc getHasMarketValuesCache*(self: Service): bool =
  return self.hasMarketDetailsCache and self.hasPriceValuesCache

proc updateTokenPrices*(self: Service, updatedPrices: Table[string, float64]) =
  var anyUpdated = false
  for tokenKey, price in updatedPrices:
    if not self.tokenPriceTable.hasKey(tokenKey) or self.tokenPriceTable[tokenKey] != price:
      anyUpdated = true
      self.tokenPriceTable[tokenKey] = price
  if anyUpdated:
    self.events.emit(SIGNAL_TOKENS_PRICES_UPDATED, Args())

proc addNewCommunityToken*(self: Service, token: TokenItem) =
  if self.allGroupsByKey.hasKey(token.groupKey):
    let tokens = self.allGroupsByKey[token.groupKey].tokens
    for t in tokens:
      if t.key == token.key:
        return
  self.refreshTokens()