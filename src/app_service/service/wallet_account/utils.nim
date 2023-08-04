#################################################
# Common functions
#################################################

proc priorityTokenCmp(a, b: WalletTokenDto): int =
  for symbol in @["ETH", "SNT", "DAI", "STT"]:
    if a.symbol == symbol:
      return -1
    if b.symbol == symbol:
      return 1
  cmp(a.name, b.name)

proc walletAccountsCmp(x, y: WalletAccountDto): int =
  cmp(x.position, y.position)

proc hex2Balance*(input: string, decimals: int): string =
  var value = fromHex(Stuint[256], input)
  if decimals == 0:
    return fmt"{value}"
  var p = u256(10).pow(decimals)
  var i = value.div(p)
  var r = value.mod(p)
  var leading_zeros = "0".repeat(decimals - ($r).len)
  var d = fmt"{leading_zeros}{$r}"
  result = $i
  if(r > 0): result = fmt"{result}.{d}"

proc responseHasNoErrors(procName: string, response: RpcResponse[JsonNode]): bool =
  var errMsg = ""
  if not response.error.isNil:
    errMsg = "(" & $response.error.code & ") " & response.error.message
  elif response.result.kind == JObject and response.result.contains("error"):
    errMsg = response.result["error"].getStr
  if(errMsg.len == 0):
    return true
  error "error: ", procName=procName, errDesription = errMsg
  return false

proc allBalancesForAllTokensHaveError(tokens: seq[WalletTokenDto]): bool =
    for token in tokens:
      for chainId, balanceDto in token.balancesPerChain:
        if not balanceDto.hasError:
          return false
    return true

proc anyTokenHasBalanceForAnyChain(tokens: seq[WalletTokenDto]): bool =
  for token in tokens:
    if len(token.balancesPerChain) > 0:
      return true
  return false

proc allMarketValuesForAllTokensHaveError(tokens: seq[WalletTokenDto]): bool =
  for token in tokens:
    for currency, marketDto in token.marketValuesPerCurrency:
      if not marketDto.hasError:
        return false
  return true

proc anyTokenHasMarketValuesForAnyChain(tokens: seq[WalletTokenDto]): bool =
  for token in tokens:
    if len(token.marketValuesPerCurrency) > 0:
      return true
  return false

#################################################
# Remote functions
#################################################

proc getAccountsFromDb(): seq[WalletAccountDto] =
  try:
    let response = status_go_accounts.getAccounts()
    return response.result.getElems().map(
        x => x.toWalletAccountDto()
      ).filter(a => not a.isChat)
  except Exception as e:
    error "error: ", procName="getAccounts", errName = e.name, errDesription = e.msg

proc getWatchOnlyAccountsFromDb(): seq[WalletAccountDto] =
  try:
    let response = status_go_accounts.getWatchOnlyAccounts()
    return response.result.getElems().map(x => x.toWalletAccountDto())
  except Exception as e:
    error "error: ", procName="getWatchOnlyAccounts", errName = e.name, errDesription = e.msg

proc getKeypairsFromDb(): seq[KeypairDto] =
  try:
    let response = status_go_accounts.getKeypairs()
    return response.result.getElems().map(x => x.toKeypairDto())
  except Exception as e:
    error "error: ", procName="getKeypairs", errName = e.name, errDesription = e.msg

proc getKeypairByKeyUidFromDb(keyUid: string): KeypairDto =
  if keyUid.len == 0:
    return
  try:
    let response = status_go_accounts.getKeypairByKeyUid(keyUid)
    if not response.error.isNil:
      return
    return response.result.toKeypairDto()
  except Exception as e:
    info "no known keypair", keyUid=keyUid, procName="getKeypairByKeyUid", errName = e.name, errDesription = e.msg

proc getEnsName(address: string, chainId: int): string =
  try:
    let response = backend.getName(chainId, address)
    return response.result.getStr
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription

proc hasPairedDevices(): bool =
  try:
    let response = backend.hasPairedDevices()
    return response.result.getBool
  except Exception as e:
    error "error: ", errDesription=e.msg
