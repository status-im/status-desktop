const noGasErrorCode = "WR-002"

# This method will group the account assets by symbol (in case of communiy, the token address)
proc onAllTokensBuilt*(self: Service, response: string) {.slot.} =
  var accountAddresses: seq[string] = @[]
  var accountTokens: seq[GroupedTokenItem] = @[]

  defer:
    let timestamp = getTime().toUnix()
    self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, TokensPerAccountArgs(accountAddresses:accountAddresses, accountTokens: accountTokens, timestamp: timestamp))

  try:
    let responseObj = response.parseJson
    var storeResult: bool
    var resultObj: JsonNode
    discard responseObj.getProp("storeResult", storeResult)
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
            var tokenDto = Json.decode($token, TokenDto, allowUnknownFields = true)
            if not token{"hasError"}.getBool:
              allTokensHaveError = false

            var balancesPerChainObj: JsonNode
            if(token.getProp("balancesPerChain", balancesPerChainObj)):
              for _, balanceObj in balancesPerChainObj:
                # update tokenDto with the chainId and address
                tokenDto.chainID = balanceObj{"chainId"}.getInt
                tokenDto.address = balanceObj{"address"}.getStr

                # Expecting "<nil>" values comming from status-go when the entry is nil
                var rawBalance: Uint256 = u256(0)
                let rawBalanceStr = balanceObj{"rawBalance"}.getStr
                if not rawBalanceStr.contains("nil"):
                  rawBalance = rawBalanceStr.parse(Uint256)

                var balance1DayAgo: Uint256 = u256(0)
                let balance1DayAgoStr = balanceObj{"balance1DayAgo"}.getStr
                if not balance1DayAgoStr.contains("nil"):
                  balance1DayAgo = stint.parse(balance1DayAgoStr, UInt256)

                let tokenGroupKey = tokenDto.tokenGroupKey()
                if groupedAccountsTokensBalances.hasKey(tokenGroupKey):
                  groupedAccountsTokensBalances[tokenGroupKey].balancesPerAccount.add(BalanceItem(account: accountAddress,
                    chainId: tokenDto.chainID,
                    balance: rawBalance,
                    balance1DayAgo: balance1DayAgo))
                else:
                  groupedAccountsTokensBalances[tokenGroupKey] = GroupedTokenItem(
                    key: tokenGroupKey,
                    symbol: tokenDto.symbol,
                    balancesPerAccount: @[BalanceItem(account: accountAddress, chainId: tokenDto.chainID, balance: rawBalance, balance1DayAgo: balance1DayAgo)]
                    )

        # set assetsLoading to false once the tokens are loaded
        self.updateAssetsLoadingState(accountAddress, false)
        accountTokens = toSeq(groupedAccountsTokensBalances.values)
    if storeResult and not allTokensHaveError:
      self.hasBalanceCache = true
      self.groupedAccountsTokensTable = groupedAccountsTokensBalances
      self.groupedAccountsTokensList = accountTokens
  except Exception as e:
    error "error: ", procName="onAllTokensBuilt", errName = e.name, errDesription = e.msg

proc buildAllTokens*(self: Service, accounts: seq[string], store: bool) =
  if not main_constants.WALLET_ENABLED or
    accounts.len == 0:
      return

  # set assetsLoading to true as the tokens are being loaded
  for waddress in accounts:
    self.updateAssetsLoadingState(waddress, true)

  let arg = BuildTokensTaskArg(
    tptr: prepareTokensTask,
    vptr: cast[uint](self.vptr),
    slot: "onAllTokensBuilt",
    accounts: accounts,
    storeResult: store
  )
  self.threadpool.start(arg)

proc getTotalCurrencyBalance*(self: Service, addresses: seq[string], chainIds: seq[int]): float64 =
  var totalBalance: float64 = 0.0
  for token in self.groupedAccountsTokensList:
    let price = self.tokenService.getPriceBySymbol(token.symbol)
    let balances = token.balancesPerAccount.filter(a => addresses.contains(a.account) and chainIds.contains(a.chainId))
    for balance in balances:
      totalBalance = totalBalance + (self.currencyService.parseCurrencyValue(token.key, balance.balance)*price)
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
    self.buildAllTokens(@[address], store = false)
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
          totalTokenBalance += self.currencyService.parseCurrencyValue(token.key, balance.balance)
  return totalTokenBalance

proc getTokenBalance*(self: Service, address: string, chainId: int, groupedTokensKey: string): float64 =
  var totalTokenBalance = 0.0
  for token in self.groupedAccountsTokensList:
    if token.key == groupedTokensKey:
      let balances = token.balancesPerAccount.filter(b => address == b.account and chainId == b.chainId)
      for balance in balances:
        totalTokenBalance = totalTokenBalance + self.currencyService.parseCurrencyValue(token.key, balance.balance)
  return totalTokenBalance

proc reloadAccountTokens*(self: Service) =
  try:
    discard backend.restartWalletReloadTimer()
  except Exception as e:
    let errDesription = e.msg
    error "error restartWalletReloadTimer: ", errDesription

  let addresses = self.getWalletAddresses()
  self.buildAllTokens(addresses, store = true)

proc parseCurrencyValue*(self: Service, groupedTokenKey: string, amountInt: UInt256): float64 =
  return self.currencyService.parseCurrencyValue(groupedTokenKey, amountInt)
