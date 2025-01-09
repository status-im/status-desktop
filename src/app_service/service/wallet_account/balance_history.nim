proc tokenBalanceHistoryDataResolved*(self: Service, response: string) {.slot.} =
  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    warn "blance history response is not a json object"
    return

  self.events.emit(
    SIGNAL_BALANCE_HISTORY_DATA_READY, TokenBalanceHistoryDataArgs(result: response)
  )

proc fetchHistoricalBalanceForTokenAsJson*(
    self: Service,
    addresses: seq[string],
    tokenSymbol: string,
    currencySymbol: string,
    timeInterval: BalanceHistoryTimeInterval,
) =
  var chainIds: seq[int] = self.networkService.getEnabledChainIds()
  let arg = GetTokenBalanceHistoryDataTaskArg(
    tptr: getTokenBalanceHistoryDataTask,
    vptr: cast[uint](self.vptr),
    slot: "tokenBalanceHistoryDataResolved",
    chainIds: chainIds,
    addresses: addresses,
    tokenSymbol: tokenSymbol,
    currencySymbol: currencySymbol,
    timeInterval: timeInterval,
  )
  self.threadpool.start(arg)
  return
