const noGasErrorCode = "WR-002"

# This method will group the account assets by symbol (in case of communiy, the token address)
proc onAllTokensBuilt*(self: Service, response: string) {.slot.} =
  var accountAddresses: seq[string] = @[]
  var accountTokens: seq[GroupedTokenItem] = @[]
  defer:
    self.fetchingBalancesInProgress = false
    let timestamp = getTime().toUnix()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, TokensPerAccountArgs(accountAddresses:accountAddresses, accountTokens: accountTokens, timestamp: timestamp))

    if self.addressesWaitingForBalanceToFetch.len > 0:
      let addressesToFetch = self.addressesWaitingForBalanceToFetch
      self.addressesWaitingForBalanceToFetch = @[]
      self.buildAllTokens(addressesToFetch, forceRefresh = true)

  try:
    let responseObj = response.parseJson
    var resultObj: JsonNode
    discard responseObj.getProp("result", resultObj)

    var groupedAccountsTokensBalances = self.groupedAccountsTokensTable
    var allTokensHaveError: bool = true
    if resultObj.kind == JObject:
      for accountAddress, tokensDetailsObj in resultObj:
        accountAddresses.add(accountAddress)

        # Delete all existing entries for the account for whom assets were requested,
        # for a new account the balances per address per chain will simply be appended later
        var tokensToBeDeleted: seq[string] = @[]
        for tokenkey, token in groupedAccountsTokensBalances:
          token.balancesPerAccount = token.balancesPerAccount.filter(balanceItem => balanceItem.account != accountAddress)
          if token.balancesPerAccount.len == 0:
            tokensToBeDeleted.add(tokenkey)

        for t in tokensToBeDeleted:
          groupedAccountsTokensBalances.del(t)

        if tokensDetailsObj.kind == JArray:
          for token in tokensDetailsObj.getElems():

            let symbol = token{"symbol"}.getStr
            let communityId = token{"community_data"}{"id"}.getStr
            if not token{"hasError"}.getBool:
              allTokensHaveError = false

            var balancesPerChainObj: JsonNode
            if(token.getProp("balancesPerChain", balancesPerChainObj)):
              for chainId, balanceObj in balancesPerChainObj:
                let chainId = balanceObj{"chainId"}.getInt
                let address = balanceObj{"address"}.getStr
                let flatTokensKey = $chainId & address

                # Expecting "<nil>" values comming from status-go when the entry is nil
                var rawBalance: Uint256 = u256(0)
                let rawBalanceStr = balanceObj{"rawBalance"}.getStr
                if not rawBalanceStr.contains("nil"):
                  rawBalance = rawBalanceStr.parse(Uint256)

                let token_by_symbol_key = if communityId.isEmptyOrWhitespace: symbol
                                          else: address
                if groupedAccountsTokensBalances.hasKey(token_by_symbol_key):
                  groupedAccountsTokensBalances[token_by_symbol_key].balancesPerAccount.add(BalanceItem(account: accountAddress,
                    chainId: chainId,
                    balance: rawBalance))
                else:
                  groupedAccountsTokensBalances[token_by_symbol_key] = GroupedTokenItem(
                    tokensKey: token_by_symbol_key,
                    symbol: symbol,
                    balancesPerAccount: @[BalanceItem(account: accountAddress, chainId: chainId, balance: rawBalance)]
                    )

        # set assetsLoading to false once the tokens are loaded
        self.updateAssetsLoadingState(accountAddress, false)
        accountTokens = toSeq(groupedAccountsTokensBalances.values)
    if not allTokensHaveError:
      self.hasBalanceCache = true
      self.groupedAccountsTokensTable = groupedAccountsTokensBalances
      self.groupedAccountsTokensList = accountTokens
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
  for token in self.groupedAccountsTokensList:
    let price = self.tokenService.getPriceBySymbol(token.symbol)
    let balances = token.balancesPerAccount.filter(a => addresses.contains(a.account) and chainIds.contains(a.chainId))
    for balance in balances:
      totalBalance = totalBalance + (self.parseCurrencyValueByTokensKey(token.tokensKey, balance.balance)*price)
  return totalBalance

proc getGroupedAccountsAssetsList*(self: Service): var seq[GroupedTokenItem] =
  return self.groupedAccountsTokensList

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

proc allAccountsTokenBalance*(self: Service, symbol: string): float64 =
  var totalTokenBalance = 0.0
  let accountsAddresses = self.getWalletAccounts().filter(n => n.walletType == WalletTypeWatch).map(n => n.address)
  for token in self.groupedAccountsTokensList:
    if token.symbol == symbol:
      for balance in token.balancesPerAccount:
        if accountsAddresses.contains(balance.account):
          totalTokenBalance += self.parseCurrencyValueByTokensKey(token.tokensKey, balance.balance)
  return totalTokenBalance

proc getTokenBalance*(self: Service, address: string, chainId: int, tokensKey: string): float64 =
  var totalTokenBalance = 0.0
  for token in self.groupedAccountsTokensList:
    if token.tokensKey == tokensKey:
      let balances = token.balancesPerAccount.filter(b => address == b.account and chainId == b.chainId)
      for balance in balances:
        totalTokenBalance = totalTokenBalance + self.parseCurrencyValueByTokensKey(token.tokensKey, balance.balance)
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

proc parseCurrencyValueByTokensKey*(self: Service, tokensKey: string, amountInt: UInt256): float64 =
  return self.currencyService.parseCurrencyValueByTokensKey(tokensKey, amountInt)

proc getCurrencyFormat(self: Service, tokensKey: string): CurrencyFormatDto =
  var symbol: string = ""
  for token in self.tokenService.getTokenBySymbolList():
    if token.key == tokensKey:
      symbol = token.symbol
  return self.currencyService.getCurrencyFormat(symbol)
