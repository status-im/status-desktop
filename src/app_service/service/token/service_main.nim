proc rebuildMarketData*(self: Service) =
  self.fetchTokensMarketValues() # TODO: if the only place where we can see these details is account's details page, we should fetch this on demand, no need to have local cache
  self.fetchTokensPrices()

proc refreshTokens(self: Service) =
  self.allTokens = getTokensForActiveNetworksMode()
  self.allTokenLists = getAllTokenLists()

  var tokensGroupsByGroupKey: Table[string, TokenGroupItem]
  for token in self.allTokens:
    let groupKey = token.groupKey
    if not tokensGroupsByGroupKey.hasKey(groupKey):
      tokensGroupsByGroupKey[groupKey] = TokenGroupItem(
        key: groupKey,
        name: token.name,
        symbol: token.symbol,
        decimals: token.decimals,
        logoUri: token.logoUri
      )
    tokensGroupsByGroupKey[groupKey].addToken(token)
  self.allTokenGroups = toSeq(tokensGroupsByGroupKey.values)

  self.rebuildMarketData()
  self.fetchTokensDetails() # TODO: if the only place where we can see these details is account's details page, we should fetch this on demand, no need to have local cache
  self.fetchTokenPreferences()
  # notify modules
  self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())

proc init*(self: Service) =
  self.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    case data.eventType:
      of "wallet-tick-reload":
        self.rebuildMarketData()
  # update and populate internal list and then emit signal when new custom token detected?
  self.events.on(SignalType.WalletTokensListsUpdated.event) do(e:Args):
    self.refreshTokens()

  self.refreshTokens()

proc getCurrency*(self: Service): string =
  return self.settingsService.getCurrency()

proc getAllTokens*(self: Service): var seq[TokenItem] =
  return self.allTokens

proc getAllTokenGroups*(self: Service): var seq[TokenGroupItem] =
  return self.allTokenGroups

proc getAllTokenLists*(self: Service): var seq[TokenListItem] =
  return self.allTokenLists

proc getTokenByChainAddress*(self: Service, chainId: int, address: string): TokenItem =
  return getTokenByChainAddress(chainId, address)

proc getTokenByKey*(self: Service, key: string): TokenItem =
  let tokens = getTokensByKeys(@[key])
  if tokens.len > 0:
    return tokens[0]
  return nil

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
  for tokenSymbol, price in updatedPrices:
    if not self.tokenPriceTable.hasKey(tokenSymbol) or self.tokenPriceTable[tokenSymbol] != price:
      anyUpdated = true
      self.tokenPriceTable[tokenSymbol] = price
  if anyUpdated:
    self.events.emit(SIGNAL_TOKENS_PRICES_UPDATED, Args())

proc addNewCommunityToken*(self: Service, token: TokenItem) =
  let sourceName = "custom"
  let tokenType = TokenType.ERC20

  var updated = false
  # let unique_key = token.key()
  # if not any(self.flatTokenList, proc (x: TokenItem): bool = x.key == unique_key):
  #   self.flatTokenList.add(TokenItem(
  #     crossChainId: token.crossChainId,
  #     name: token.name,
  #     symbol: token.symbol,
  #     sources: @[sourceName],
  #     chainID: token.chainID,
  #     address: token.address,
  #     decimals: token.decimals,
  #     image: token.logoUri,
  #     `type`: tokenType,
  #     communityId: token.communityData.id))
  #   self.flatTokenList.sort(cmpTokenItem)
  #   updated = true

  # let token_by_symbol_key = token.bySymbolModelKey()
  # if not any(self.tokenBySymbolList, proc (x: TokenBySymbolItem): bool = x.key == token_by_symbol_key):
  #   self.tokenBySymbolList.add(TokenBySymbolItem(
  #       key: token_by_symbol_key,
  #       name: token.name,
  #       symbol: token.symbol,
  #       sources: @[sourceName],
  #       addressPerChainId: @[AddressPerChain(chainId: token.chainID, address: token.address)],
  #       decimals: token.decimals,
  #       image: token.logoUri,
  #       `type`: tokenType,
  #       communityId: token.communityData.id))
  #   self.tokenBySymbolList.sort(cmpTokenBySymbolItem)
  #   updated = true

  # self.tokenBySymbolList.sort(cmpTokenBySymbolItem)

  if updated:
    self.events.emit(SIGNAL_TOKENS_LIST_UPDATED, Args())