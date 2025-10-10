const noGasErrorCode = "WR-002"

# This method will group the account assets by symbol (in case of communiy, the token address)
proc onAllTokensBuilt*(self: Service, response: string) {.slot.} =
  var accountAddresses: seq[string] = @[]
  var groupedAssets: seq[GroupedTokenItem] = @[]
  defer:
    self.fetchingBalancesInProgress = false
    let timestamp = getTime().toUnix()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, TokensPerAccountArgs(
      accountAddresses:accountAddresses,
      accountTokens: groupedAssets,
      timestamp: timestamp
    ))

    if self.addressesWaitingForBalanceToFetch.len > 0:
      let addressesToFetch = self.addressesWaitingForBalanceToFetch
      self.addressesWaitingForBalanceToFetch = @[]
      self.buildAllTokens(addressesToFetch, forceRefresh = true)

  try:
    let responseObj = response.parseJson
    var resultObj: JsonNode
    discard responseObj.getProp("result", resultObj)

    var groupedTokensBalances: Table[string, GroupedTokenItem] # [crossChainId (or tokenKey if crossChainId is empty), GroupedTokenItem]
    var allTokensHaveError: bool = true
    if resultObj.kind == JObject:
      for accountAddress, balanceDetailsObj in resultObj:
        accountAddresses.add(accountAddress)

        if balanceDetailsObj.kind == JArray:
          for balanceDetail in balanceDetailsObj.getElems():
            let tokenItem = createTokenItem(TokenDto(
              address: balanceDetail{"tokenAddress"}.getStr,
              chainId: balanceDetail{"tokenChainId"}.getInt
            ))

            let token = self.tokenService.getTokenByKey(tokenItem.key)
            if token.isNil:
              warn "error: ", procName="onAllTokensBuilt", errName="received balance for an unknown token", tokenKey=tokenItem.key
              continue

            # Expecting "<nil>" values comming from status-go when the entry is nil, but with new format it should never be nil
            var rawBalance: Uint256 = u256(0)
            let rawBalanceStr = balanceDetail{"rawBalance"}.getStr
            if not rawBalanceStr.contains("nil"):
              rawBalance = rawBalanceStr.parse(Uint256)

            if not balanceDetail{"hasError"}.getBool:
              allTokensHaveError = false

            let groupKey = token.groupKey
            if not groupedTokensBalances.hasKey(groupKey):
              groupedTokensBalances[groupKey] = GroupedTokenItem(key: groupKey)

            groupedTokensBalances[groupKey].balancesPerAccount.add(BalanceItem(
              account: accountAddress,
              tokenKey: groupKey,
              tokenAddress: token.address,
              chainId: token.chainId,
              balance: rawBalance
            ))

        # set assetsLoading to false once the tokens are loaded
        self.updateAssetsLoadingState(accountAddress, false)

    groupedAssets = toSeq(groupedTokensBalances.values)
    if not allTokensHaveError:
      self.hasBalanceCache = true
      self.groupedAssets = groupedAssets
  except Exception as e:
    error "error: ", procName="onAllTokensBuilt", errName = e.name, errDesription = e.msg

proc buildAllTokens*(self: Service, accounts: seq[string], forceRefresh: bool) =
  if not main_constants.WALLET_ENABLED or
    accounts.len == 0:
      return

  if self.fetchingBalancesInProgress:
    self.addressesWaitingForBalanceToFetch.add(accounts)
    return

  self.fetchingBalancesInProgress = true

  # set assetsLoading to true as the tokens are being loaded
  for waddress in accounts:
    self.updateAssetsLoadingState(waddress, true)

  var uniqueAddresses: HashSet[string] = toHashSet(accounts)
  let arg = BuildTokensTaskArg(
    tptr: prepareTokensTask,
    vptr: cast[uint](self.vptr),
    slot: "onAllTokensBuilt",
    accounts: toSeq(uniqueAddresses),
    forceRefresh: forceRefresh
  )
  self.threadpool.start(arg)

proc getTotalCurrencyBalance*(self: Service, addresses: seq[string], chainIds: seq[int]): float64 =
  var totalBalance: float64 = 0.0
  ## TODO: implement this - check `groupedAccountsTokensList`
  # for token in self.groupedAccountsTokensList:
  #   let price = self.tokenService.getPriceForToken(token.key())
  #   let balances = token.balancesPerAccount.filter(a => addresses.contains(a.account) and chainIds.contains(a.chainId))
  #   for balance in balances:
  #     totalBalance = totalBalance + (self.getCurrencyValueForToken(token.tokensKey, balance.balance)*price)
  return totalBalance

proc getGroupedAssetsList*(self: Service): var seq[GroupedTokenItem] =
  return self.groupedAssets

proc getTokensMarketValuesLoading*(self: Service): bool =
  return self.tokenService.getTokensMarketValuesLoading()

proc getHasBalanceCache*(self: Service): bool =
  return self.hasBalanceCache

proc getChainsWithNoGasFromError*(self: Service, errCode: string, errDescription: string): Table[int, string] =
  ## Extracts the chainId and token from the error description for chains with no gas.
  ## If the error code is not "WR-002", an empty table is returned.
  result = initTable[int, string]()

  if errCode == noGasErrorCode:
    try:
      let jsonData = parseJson(errDescription)
      let token: string = jsonData["token"].getStr()
      let chainId: int = jsonData["chainId"].getInt()
      result[chainId] = token
    except Exception as e:
      error "error: ", procName="getChainsWithNoGasFromError", errName=e.name, errDesription=e.msg

proc getCurrency*(self: Service): string =
  return self.settingsService.getCurrency()

proc getOrFetchBalanceForAddressInPreferredCurrency*(self: Service, address: string): tuple[balance: float64, fetched: bool] =
  let acc = self.getAccountByAddress(address)
  if acc.isNil:
    result.balance = 0.0
    result.fetched = false
    return
  let chainIds = self.networkService.getCurrentNetworksChainIds()
  result.balance = self.getTotalCurrencyBalance(@[acc.address], chainIds)
  result.fetched = true

proc getTokenBalance*(self: Service, address: string, chainId: int, tokenKey: string): float64 =
  let token = self.tokenService.getTokenByKey(tokenKey)
  if token.isNil:
    return 0.0
  var totalTokenBalance = 0.0
  ## TODO: implement this - check `balancesPerAccount`
  # let balances = token.balancesPerAccount.filter(b => address == b.account and chainId == b.chainId)
  # for balance in balances:
  #   totalTokenBalance = totalTokenBalance + self.getCurrencyValueForToken(token.tokenKey, balance.balance)
  return totalTokenBalance

proc reloadAccountTokens*(self: Service) =
  try:
    discard backend.restartWalletReloadTimer()
  except Exception as e:
    let errDesription = e.msg
    error "error restartWalletReloadTimer: ", errDesription

  let addresses = self.getWalletAddresses()
  self.buildAllTokens(addresses, forceRefresh = true)

  try:
    discard collectibles.refetchOwnedCollectibles()
  except Exception as e:
    let errDesription = e.msg
    error "error refetchOwnedCollectibles: ", errDesription

proc getCurrencyValueForToken*(self: Service, tokenKey: string, amountInt: UInt256): float64 =
  return self.currencyService.getCurrencyValueForToken(tokenKey, amountInt)

proc getCurrencyFormat*(self: Service, key: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(key)
