proc tokenBalanceHistoryDataResolved*(self: Service, response: string) {.slot.} =
  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    warn "blance history response is not a json object"
    return

  self.events.emit(SIGNAL_BALANCE_HISTORY_DATA_READY, TokenBalanceHistoryDataArgs(
    result: response
  ))

proc fetchHistoricalBalanceForTokenAsJson*(self: Service, addresses: seq[string], tokenSymbol: string, currencySymbol: string, timeInterval: BalanceHistoryTimeInterval) =
  # create an empty list of chain ids
  var chainIds: seq[int] = self.networkService.getCurrentNetworks().filter(n => n.isEnabled and n.nativeCurrencySymbol == tokenSymbol).map(n => n.chainId)
  if chainIds.len == 0:
    let tokenChainIds = self.tokenService.getFlatTokensList().filter(t => t.symbol == tokenSymbol and t.communityId.isEmptyOrWhitespace).map(t => t.chainID)
    chainIds = concat(chainIds, tokenChainIds)

  if chainIds.len == 0:
    error "failed to find a network with the symbol", tokenSymbol
    return

  let arg = GetTokenBalanceHistoryDataTaskArg(
    tptr: cast[ByteAddress](getTokenBalanceHistoryDataTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "tokenBalanceHistoryDataResolved",
    chainIds: chainIds,
    addresses: addresses,
    tokenSymbol: tokenSymbol,
    currencySymbol: currencySymbol,
    timeInterval: timeInterval
  )
  self.threadpool.start(arg)
  return
