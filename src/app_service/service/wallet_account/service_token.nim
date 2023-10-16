  proc storeTokensForAccount*(self: Service, address: string, tokens: seq[WalletTokenDto], areBalancesCached: bool, areMarketValuesCached: bool) =
    let acc = self.getAccountByAddress(address)
    if acc.isNil:
      return
    self.accountsTokens[address] = tokens
    acc.hasBalanceCache = areBalancesCached
    acc.hasMarketValuesCache = areMarketValuesCached

proc updateReceivedTokens*(self: Service, address: string, tokens: var seq[WalletTokenDto]) =
    let acc = self.getAccountByAddress(address)
    if acc.isNil or not self.accountsTokens.hasKey(address):
      return
    let allBalancesForAllTokensHaveError = allBalancesForAllTokensHaveError(tokens)
    let allMarketValuesForAllTokensHaveError = allMarketValuesForAllTokensHaveError(tokens)

    for storedToken in self.accountsTokens[address]:
      for token in tokens.mitems:
        if storedToken.name == token.name:
          if allBalancesForAllTokensHaveError:
            token.balancesPerChain = storedToken.balancesPerChain
          if allMarketValuesForAllTokensHaveError:
            token.marketValuesPerCurrency = storedToken.marketValuesPerCurrency

proc getTokensByAddress*(self: Service, address: string): seq[WalletTokenDto] =
  if not self.accountsTokens.hasKey(address):
    return
  return self.accountsTokens[address]

proc getTokensByAddresses*(self: Service, addresses: seq[string]): seq[WalletTokenDto] =
  var tokens = initTable[string, WalletTokenDto]()
  for address in addresses:
    if not self.accountsTokens.hasKey(address):
      continue
    for token in self.accountsTokens[address]:
      if not tokens.hasKey(token.symbol):
        let newToken = token.copyToken()
        tokens[token.symbol] = newToken
        continue

      for chainId, balanceDto in token.balancesPerChain:
        if not tokens[token.symbol].balancesPerChain.hasKey(chainId):
          tokens[token.symbol].balancesPerChain[chainId] = balanceDto
          continue

        tokens[token.symbol].balancesPerChain[chainId].balance += balanceDto.balance

  result = toSeq(tokens.values)
  result.sort(priorityTokenCmp)

proc onAllTokensBuilt*(self: Service, response: string) {.slot.} =
  try:
    let chainIds = self.networkService.getNetworks().map(n => n.chainId)

    let responseObj = response.parseJson
    var storeResult: bool
    var resultObj: JsonNode
    discard responseObj.getProp("storeResult", storeResult)
    discard responseObj.getProp("result", resultObj)

    var data = TokensPerAccountArgs()
    data.accountsTokens = initOrderedTable[string, seq[WalletTokenDto]]()
    data.hasBalanceCache = false
    data.hasMarketValuesCache = false
    if resultObj.kind == JObject:
      for wAddress, tokensDetailsObj in resultObj:
        if tokensDetailsObj.kind == JArray:
          var tokens: seq[WalletTokenDto]
          tokens = map(tokensDetailsObj.getElems(), proc(x: JsonNode): WalletTokenDto = x.toWalletTokenDto())
          tokens.sort(priorityTokenCmp)
          self.updateReceivedTokens(wAddress, tokens)
          let hasBalanceCache = anyTokenHasBalanceForAnyChain(tokens)
          let hasMarketValuesCache = anyTokenHasMarketValuesForAnyChain(tokens)
          data.accountsTokens[wAddress] = @[]
          deepCopy(data.accountsTokens[wAddress], tokens)
          data.hasBalanceCache = data.hasBalanceCache or hasBalanceCache
          data.hasMarketValuesCache = data.hasMarketValuesCache or hasMarketValuesCache

          # set assetsLoading to false once the tokens are loaded
          self.updateAssetsLoadingState(wAddress, false)

          if storeResult:
            self.storeTokensForAccount(wAddress, tokens, hasBalanceCache, hasMarketValuesCache)
            self.tokenService.updateTokenPrices(tokens) # For efficiency. Will be removed when token info fetching gets moved to the tokenService
    self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, data)
  except Exception as e:
    error "error: ", procName="onAllTokensBuilt", errName = e.name, errDesription = e.msg

proc buildAllTokens(self: Service, accounts: seq[string], store: bool) =
  if not main_constants.WALLET_ENABLED or
    accounts.len == 0:
      return

  # set assetsLoading to true as the tokens are being loaded
  for waddress in accounts:
    self.updateAssetsLoadingState(waddress, true)

  let arg = BuildTokensTaskArg(
    tptr: cast[ByteAddress](prepareTokensTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onAllTokensBuilt",
    accounts: accounts,
    storeResult: store
  )
  self.threadpool.start(arg)

proc checkRecentHistory*(self: Service, addresses: seq[string]) =
  if(not main_constants.WALLET_ENABLED):
    return
  try:
    let chainIds = self.networkService.getNetworks().map(a => a.chainId)
    status_go_transactions.checkRecentHistory(chainIds, addresses)
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

proc reloadAccountTokens*(self: Service) =
  let addresses = self.getWalletAddresses()
  self.buildAllTokens(addresses, store = true)
  self.checkRecentHistory(addresses)

proc getCurrency*(self: Service): string =
  return self.settingsService.getCurrency()

proc getCurrentCurrencyIfEmpty(self: Service, currency = ""): string =
  if currency != "":
    return currency
  else:
    return self.getCurrency()

proc getCurrencyBalance*(self: Service, address: string, chainIds: seq[int], currency: string): float64 =
  if not self.accountsTokens.hasKey(address):
    return
  return self.accountsTokens[address].map(t => t.getCurrencyBalance(chainIds, currency)).foldl(a + b, 0.0)

proc getTotalCurrencyBalance*(self: Service, addresses: seq[string], currency: string = ""): float64 =
  let chainIds = self.networkService.getNetworks().filter(a => a.enabled).map(a => a.chainId)
  let accounts = self.getWalletAccounts().filter(w => addresses.contains(w.address))
  return accounts.map(a => self.getCurrencyBalance(a.address, chainIds, self.getCurrentCurrencyIfEmpty(currency))).foldl(a + b, 0.0)

proc findTokenSymbolByAddress*(self: Service, address: string): string =
  return self.tokenService.findTokenSymbolByAddress(address)

proc getOrFetchBalanceForAddressInPreferredCurrency*(self: Service, address: string): tuple[balance: float64, fetched: bool] =
  let acc = self.getAccountByAddress(address)
  if acc.isNil:
    self.buildAllTokens(@[address], store = false)
    result.balance = 0.0
    result.fetched = false
    return
  let chainIds = self.networkService.getNetworks().map(n => n.chainId)
  result.balance = self.getCurrencyBalance(acc.address, chainIds, self.getCurrentCurrencyIfEmpty())
  result.fetched = true

proc getTokenBalanceOnChain*(self: Service, address: string, chainId: int, symbol: string): float64 =
  if not self.accountsTokens.hasKey(address):
    return 0.0
  for token in self.accountsTokens[address]:
    if token.symbol == symbol and token.balancesPerChain.hasKey(chainId):
      return token.balancesPerChain[chainId].balance
  return 0.0

proc allAccountsTokenBalance*(self: Service, symbol: string): float64 =
  var totalTokenBalance = 0.0
  for walletAccount in self.getWalletAccounts():
    if walletAccount.walletType == WalletTypeWatch or
      not self.accountsTokens.hasKey(walletAccount.address):
        continue
    for token in self.accountsTokens[walletAccount.address]:
      if token.symbol == symbol:
        totalTokenBalance += token.getTotalBalanceOfSupportedChains()
  return totalTokenBalance
