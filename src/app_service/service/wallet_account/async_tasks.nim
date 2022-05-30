#################################################
# Async load derivedAddreses
#################################################

type
  GetDerivedAddressesTaskArg* = ref object of QObjectTaskArg
    password: string
    derivedFrom: string
    path: string
    pageSize: int
    pageNumber: int

const getDerivedAddressesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressesTaskArg](argEncoded)
  try:
    let response = status_go_accounts.getDerivedAddressList(arg.password, arg.derivedFrom, arg.path, arg.pageSize, arg.pageNumber)

    let output = %*{
      "derivedAddresses": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
        "derivedAddresses": "",
        "error": fmt"Error getting derived address list: {e.msg}"
    }
    arg.finish(output)

type
  GetDerivedAddressesForMnemonicTaskArg* = ref object of QObjectTaskArg
    mnemonic: string
    path: string
    pageSize: int
    pageNumber: int

const getDerivedAddressesForMnemonicTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressesForMnemonicTaskArg](argEncoded)
  try:
    let response = status_go_accounts.getDerivedAddressListForMnemonic(arg.mnemonic, arg.path, arg.pageSize, arg.pageNumber)

    let output = %*{
      "derivedAddresses": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
        "derivedAddresses": "",
        "error": fmt"Error getting derived address list for mnemonic: {e.msg}"
    }
    arg.finish(output)

type
  GetDerivedAddressForPrivateKeyTaskArg* = ref object of QObjectTaskArg
    privateKey: string

const getDerivedAddressForPrivateKeyTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetDerivedAddressForPrivateKeyTaskArg](argEncoded)
  try:
    let response = status_go_accounts.getDerivedAddressForPrivateKey(arg.privateKey)

    let output = %*{
      "derivedAddresses": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
        "derivedAddresses": "",
        "error": fmt"Error getting derived address list for private key: {e.msg}"
    }
    arg.finish(output)

#################################################
# Async timer
#################################################

type
  TimerTaskArg = ref object of QObjectTaskArg
    timeoutInMilliseconds: int

const timerTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[TimerTaskArg](argEncoded)
  sleep(arg.timeoutInMilliseconds)
  arg.finish("")

#################################################
# Async building token
#################################################

type
  BuildTokensTaskArg = ref object of QObjectTaskArg
    walletAddresses: seq[string]
    currency: string
    networks: seq[NetworkDto]

proc getCustomTokens(): seq[TokenDto] =
  try:
    let responseCustomTokens = backend.getCustomTokens()
    result = map(responseCustomTokens.result.getElems(), proc(x: JsonNode): TokenDto = x.toTokenDto(@[]))
  except Exception as e:
    error "error fetching custom tokens: ", message = e.msg

proc getTokensForChainId(chainId: int): seq[TokenDto] =
  try:
    let responseTokens = backend.getTokens(chainId)
    let defaultTokens = map(responseTokens.result.getElems(), 
      proc(x: JsonNode): TokenDto = x.toTokenDto(@[], hasIcon=true, isCustom=false)
      )
    result.add(defaultTokens)
  except Exception as e:
    error "error fetching tokens: ", message = e.msg, chainId=chainId

proc prepareSymbols(networkSymbols: seq[string], allTokens: seq[TokenDto]): seq[seq[string]] =
  # we have to use up to 300 characters in a single request when we're fetching prices
  let charsMaxLenght = 300
  result.add(@[])
  var networkSymbolsIndex = 0
  var tokenSymbolsIndex = 0
  while networkSymbolsIndex < networkSymbols.len or tokenSymbolsIndex < allTokens.len:
    var currentCharsLen = 0
    var reachTheEnd = false
    while networkSymbolsIndex < networkSymbols.len:
      if(currentCharsLen + networkSymbols[networkSymbolsIndex].len >= charsMaxLenght):
        reachTheEnd = true
        result.add(@[])
        break
      else:
        currentCharsLen += networkSymbols[networkSymbolsIndex].len + 1 # we add one for ','
        result[result.len - 1].add(networkSymbols[networkSymbolsIndex])
        networkSymbolsIndex.inc
    while not reachTheEnd and tokenSymbolsIndex < allTokens.len:
      if(currentCharsLen + allTokens[tokenSymbolsIndex].symbol.len >= charsMaxLenght):
        reachTheEnd = true
        result.add(@[])
        break
      else:
        currentCharsLen += allTokens[tokenSymbolsIndex].symbol.len + 1 # we add one for ','
        result[result.len - 1].add(allTokens[tokenSymbolsIndex].symbol)
        tokenSymbolsIndex.inc

proc fetchNativeChainBalance(chainId: int, nativeCurrencyDecimals: int, accountAddress: string): float64 =
  result = 0.0
  try:
    let nativeBalanceResponse = status_go_eth.getNativeChainBalance(chainId, accountAddress)
    result = parsefloat(hex2Balance(nativeBalanceResponse.result.getStr, nativeCurrencyDecimals))
  except Exception as e:
    error "error getting balance", message = e.msg

proc fetchPrices(networkSymbols: seq[string], allTokens: seq[TokenDto], currency: string): Table[string, float] =
  let allSymbols = prepareSymbols(networkSymbols, allTokens)
  for symbols in allSymbols:
    try:
      let response = backend.fetchPrices(symbols, currency)
      for (symbol, value) in response.result.pairs:
        result[symbol] = value.getFloat
    except Exception as e:
      error "error fetching prices: ", message = e.msg

proc getTokensBalances(walletAddresses: seq[string], allTokens: seq[TokenDto]): JsonNode =
  try:
    result = newJObject()
    let tokensAddresses = allTokens.map(t => t.addressAsString())
    # We need to check, we should use `chainIdsFromSettings` instead `chainIds` deduced from the allTokens list?
    let chainIds = deduplicate(allTokens.map(t => t.chainId)) 
    let tokensBalancesResponse = backend.getTokensBalancesForChainIDs(chainIds, walletAddresses, tokensAddresses)
    result = tokensBalancesResponse.result
  except Exception as e:
    error "error fetching tokens balances: ", message = e.msg  

proc groupNetworksBySymbol(networks: seq[NetworkDto]): Table[string, seq[NetworkDto]] =
  for network in networks:
    if not result.hasKey(network.nativeCurrencySymbol):
      result[network.nativeCurrencySymbol] = @[]
    result[network.nativeCurrencySymbol].add(network)

proc getNetworkByCurrencySymbol(networks: seq[NetworkDto], networkNativeCurrencySymbol: string): NetworkDto =
  for network in networks:
    if network.nativeCurrencySymbol != networkNativeCurrencySymbol:
      continue
    return network

proc groupTokensBySymbol(tokens: seq[TokenDto]): Table[string, seq[TokenDto]] =
  for token in tokens:
    if not result.hasKey(token.symbol):
      result[token.symbol] = @[]
    result[token.symbol].add(token)

proc getTokenForSymbol(tokens: seq[TokenDto], symbol: string): TokenDto =
  for token in tokens:
    if token.symbol != symbol:
      continue
    return token

const prepareTokensTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[BuildTokensTaskArg](argEncoded)

  var networkSymbols: seq[string]
  var chainIdsFromSettings: seq[int]
  for network in arg.networks:
    networkSymbols.add(network.nativeCurrencySymbol)
    chainIdsFromSettings.add(network.chainId)

  var allTokens: seq[TokenDto]
  allTokens.add(getCustomTokens())
  for chainId in chainIdsFromSettings:
    allTokens.add(getTokensForChainId(chainId))
  allTokens = deduplicate(allTokens)

  var prices = fetchPrices(networkSymbols, allTokens, arg.currency)
  let tokenBalances = getTokensBalances(arg.walletAddresses, allTokens)

  var builtTokensPerAccount = %*{ }
  for address in arg.walletAddresses:
    var builtTokens: seq[WalletTokenDto]

    let groupedNetworks = groupNetworksBySymbol(arg.networks)
    for networkNativeCurrencySymbol, networks in groupedNetworks.pairs:
      var balancesPerChain = initTable[int, BalanceDto]()
      for network in networks:
        let chainBalance = fetchNativeChainBalance(network.chainId, network.nativeCurrencyDecimals, address)
        balancesPerChain[network.chainId] = BalanceDto(
          balance: chainBalance,
          currencyBalance: chainBalance * prices[network.nativeCurrencySymbol]  
        )
      let networkDto = getNetworkByCurrencySymbol(arg.networks, networkNativeCurrencySymbol)
      var totalTokenBalance: BalanceDto
      totalTokenBalance.balance = toSeq(balancesPerChain.values).map(x => x.balance).foldl(a + b)
      totalTokenBalance.currencyBalance = totalTokenBalance.balance * prices[networkDto.nativeCurrencySymbol]
      builtTokens.add(WalletTokenDto(
          name: networkDto.nativeCurrencyName,
          address: "0x0000000000000000000000000000000000000000",
          symbol: networkDto.nativeCurrencySymbol,
          decimals: networkDto.nativeCurrencyDecimals,
          hasIcon: true,
          color: "blue",
          isCustom: false,
          totalBalance: totalTokenBalance,
          balancesPerChain: balancesPerChain
        )
      )

    let groupedTokens = groupTokensBySymbol(allTokens)
    for symbol, tokens in groupedTokens.pairs:
      var balancesPerChain = initTable[int, BalanceDto]()
      for token in tokens:
        let balanceForToken = tokenBalances{address}{token.addressAsString()}.getStr
        let chainBalanceForToken = parsefloat(hex2Balance(balanceForToken, token.decimals))
        balancesPerChain[token.chainId] = BalanceDto(
          balance: chainBalanceForToken,
          currencyBalance: chainBalanceForToken * prices[token.symbol]
        )
      let tokenDto = getTokenForSymbol(allTokens, symbol)
      var totalTokenBalance: BalanceDto
      totalTokenBalance.balance = toSeq(balancesPerChain.values).map(x => x.balance).foldl(a + b)
      totalTokenBalance.currencyBalance = totalTokenBalance.balance * prices[tokenDto.symbol]
      builtTokens.add(WalletTokenDto(
          name: tokenDto.name,
          address: $tokenDto.address,
          symbol: tokenDto.symbol,
          decimals: tokenDto.decimals,
          hasIcon: tokenDto.hasIcon,
          color: tokenDto.color,
          isCustom: tokenDto.isCustom,
          totalBalance: totalTokenBalance,
          balancesPerChain: balancesPerChain
        )
      )

    var tokensJArray =  newJArray()
    for wtDto in builtTokens:
      tokensJarray.add(walletTokenDtoToJson(wtDto))
    builtTokensPerAccount[address] = tokensJArray
 
  arg.finish(builtTokensPerAccount)

