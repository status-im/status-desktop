# This method will group the account assets by symbol (in case of communiy, the token address)
proc onNewAllTokensBuilt*(self: Service, response: string) {.slot.} =
  defer: self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT, TokensPerAccountArgs())
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
                  groupedAccountsTokensBalances[token_by_symbol_key].balancesPerAccount.add(BalanceItem(account:accountAddress,
                    chainId: chainId,
                    balance: rawBalance))
                else:
                  groupedAccountsTokensBalances[token_by_symbol_key] = GroupedTokenItem(
                    tokensKey: token_by_symbol_key,
                    symbol: symbol,
                    balancesPerAccount: @[BalanceItem(account:accountAddress, chainId: chainId, balance: rawBalance)]
                    )

        # set assetsLoading to false once the tokens are loaded
        self.updateAssetsLoadingState(accountAddress, false)
    if storeResult and not allTokensHaveError:
      self.hasBalanceCache = true
      self.groupedAccountsTokensTable = groupedAccountsTokensBalances
      self.groupedAccountsTokensList = toSeq(groupedAccountsTokensBalances.values)
  except Exception as e:
    error "error: ", procName="onAllTokensBuilt", errName = e.name, errDesription = e.msg

proc newBuildAllTokens*(self: Service, accounts: seq[string], store: bool) =
  if not main_constants.WALLET_ENABLED or
    accounts.len == 0:
      return

  # set assetsLoading to true as the tokens are being loaded
  for waddress in accounts:
    self.updateAssetsLoadingState(waddress, true)

  # this is emited so that the models can know that an update is about to happen
  self.events.emit(SIGNAL_WALLET_ACCOUNT_TOKENS_BEING_FETCHED, Args())

  let arg = BuildTokensTaskArg(
    tptr: cast[ByteAddress](newPrepareTokensTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onNewAllTokensBuilt",
    accounts: accounts,
    storeResult: store
  )
  self.threadpool.start(arg)

proc getTotalCurrencyBalance*(self: Service, addresses: seq[string], chainIds: seq[int]): float64 =
  var totalBalance: float64 = 0.0
  for tokensKey, token in self.groupedAccountsTokensList:
    let price = self.tokenService.getPriceBySymbol(token.symbol)
    let balances = token.balancesPerAccount.filter(a => addresses.contains(a.account) and chainIds.contains(a.chainId))
    for balance in balances:
      totalBalance = totalBalance + (self.currencyService.parseCurrencyValue(token.symbol, balance.balance)*price)
  return totalBalance

proc getGroupedAccountsAssetsList*(self: Service): var seq[GroupedTokenItem] =
  return self.groupedAccountsTokensList

proc getTokensMarketValuesLoading*(self: Service): bool =
  return self.tokenService.getTokensMarketValuesLoading()

proc getHasBalanceCache*(self: Service): bool =
  return self.hasBalanceCache
