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

type
  FetchDerivedAddressDetailsTaskArg* = ref object of QObjectTaskArg
    address: string

const fetchDerivedAddressDetailsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDerivedAddressDetailsTaskArg](argEncoded)
  var data = %* {
    "details": "",
    "error": ""
  }
  try:
    let response = status_go_accounts.getDerivedAddressDetails(arg.address)
    data["details"] = response.result
  except Exception as e:
    let err = fmt"Error getting details for an address: {e.msg}"
    data["error"] = %* err
  arg.finish(data)

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
    result = map(responseCustomTokens.result.getElems(), proc(x: JsonNode): TokenDto = x.toTokenDto(true))
  except Exception as e:
    error "error fetching custom tokens: ", message = e.msg

proc getTokensForChainId(network: NetworkDto): seq[TokenDto] =
  try:
    let responseTokens = backend.getTokens(network.chainId)
    let defaultTokens = map(
      responseTokens.result.getElems(), 
      proc(x: JsonNode): TokenDto = x.toTokenDto(network.enabled, hasIcon=true, isCustom=false)
    )
    result.add(defaultTokens)
  except Exception as e:
    error "error fetching tokens: ", message = e.msg, chainId=network.chainId

proc isNetworkEnabledForChainId(networks: seq[NetworkDto], chainId: int): bool =
  for network in networks:
    if network.chainId == chainId:
      return network.enabled

  return false

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
    if symbols.len == 0:
      continue
    
    try:
      let response = backend.fetchPrices(symbols, currency)
      for (symbol, value) in response.result.pairs:
        result[symbol] = value.getFloat
    except Exception as e:
      error "error fetching prices: ", message = e.msg

proc getMarketValues(networkSymbols: seq[string], allTokens: seq[TokenDto], currency: string): Table[string, Table[string, string]] =
  let allSymbols = prepareSymbols(networkSymbols, allTokens)
  for symbols in allSymbols:
    if symbols.len == 0:
      continue

    try:
      let response = backend.fetchMarketValues(symbols, currency)
      for (symbol, marketValue) in response.result.pairs:
        var marketValues: Table[string, string] = initTable[string, string]()
        for (key, value) in marketValue.pairs:
          marketValues[key] = value.getStr()
        result[symbol] = marketValues
    except Exception as e:
      error "error fetching markey values: ", message = e.msg

proc getTokenDetails(networkSymbols: seq[string], allTokens: seq[TokenDto]): Table[string, Table[string, string]] =
  let allSymbols = prepareSymbols(networkSymbols, allTokens)
  for symbols in allSymbols:
    if symbols.len == 0:
      continue

    try:
      let response = backend.fetchTokenDetails(symbols)
      for (symbol, tokenDetail) in response.result.pairs:
        var tokenDetails: Table[string, string] = initTable[string, string]()
        for (key, value) in tokenDetail.pairs:
          tokenDetails[key] = value.getStr()
        result[symbol] = tokenDetails
    except Exception as e:
      error "error fetching markey values: ", message = e.msg

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
  var allTokens: seq[TokenDto]

  for network in arg.networks:
    networkSymbols.add(network.nativeCurrencySymbol)
    allTokens.add(getTokensForChainId(network))
  
  allTokens.add(getCustomTokens())
  allTokens = deduplicate(allTokens)

  var prices = fetchPrices(networkSymbols, allTokens, arg.currency)
  var marketValues = getMarketValues(networkSymbols, allTokens, arg.currency)
  var tokenDetails = getTokenDetails(networkSymbols, allTokens)
  let tokenBalances = getTokensBalances(arg.walletAddresses, allTokens)

  var builtTokensPerAccount = %*{ }
  for address in arg.walletAddresses:
    var builtTokens: seq[WalletTokenDto]

    let groupedNetworks = groupNetworksBySymbol(arg.networks)
    var enabledNetworkBalance = BalanceDto(
      balance: 0.0,
      currencyBalance: 0.0
    )
    for networkNativeCurrencySymbol, networks in groupedNetworks.pairs:
      # Reset
      enabledNetworkBalance = BalanceDto(
        balance: 0.0,
        currencyBalance: 0.0
      )
      var balancesPerChain = initTable[int, BalanceDto]()
      for network in networks:
        let chainBalance = fetchNativeChainBalance(network.chainId, network.nativeCurrencyDecimals, address)
        balancesPerChain[network.chainId] = BalanceDto(
          balance: chainBalance,
          currencyBalance: chainBalance * prices[network.nativeCurrencySymbol],
          chainId: network.chainId,
          address: "0x0000000000000000000000000000000000000000",
          enabled: network.enabled,
        )
        if network.enabled:
          enabledNetworkBalance.balance += balancesPerChain[network.chainId].balance
          enabledNetworkBalance.currencyBalance += balancesPerChain[network.chainId].currencyBalance

      let networkDto = getNetworkByCurrencySymbol(arg.networks, networkNativeCurrencySymbol)
      var totalTokenBalance: BalanceDto
      totalTokenBalance.balance = toSeq(balancesPerChain.values).map(x => x.balance).foldl(a + b)
      totalTokenBalance.currencyBalance = totalTokenBalance.balance * prices[networkDto.nativeCurrencySymbol]
      var marketCap: string = ""
      var highDay: string = ""
      var lowDay: string = ""
      var changePctHour: string = ""
      var changePctDay: string = ""
      var changePct24hour: string = ""
      var change24hour: string = ""

      if(marketValues.hasKey(networkDto.nativeCurrencySymbol)):
        marketCap = marketValues[networkDto.nativeCurrencySymbol]["MKTCAP"]
        highDay = marketValues[networkDto.nativeCurrencySymbol]["HIGHDAY"]
        lowDay = marketValues[networkDto.nativeCurrencySymbol]["LOWDAY"]
        changePctHour = marketValues[networkDto.nativeCurrencySymbol]["CHANGEPCTHOUR"]
        changePctDay = marketValues[networkDto.nativeCurrencySymbol]["CHANGEPCTDAY"]
        changePct24hour = marketValues[networkDto.nativeCurrencySymbol]["CHANGEPCT24HOUR"]
        change24hour = marketValues[networkDto.nativeCurrencySymbol]["CHANGE24HOUR"]

      builtTokens.add(WalletTokenDto(
          name: networkDto.nativeCurrencyName,
          symbol: networkDto.nativeCurrencySymbol,
          decimals: networkDto.nativeCurrencyDecimals,
          hasIcon: true,
          color: "blue",
          isCustom: false,
          totalBalance: totalTokenBalance,
          enabledNetworkBalance: enabledNetworkBalance,
          balancesPerChain: balancesPerChain,
          visible: networkDto.enabled,
          description: "Ethereum is a decentralized platform that runs smart contracts (applications that run exactly as programmed without any possibility of downtime, censorship, fraud or third party interference). In the Ethereum protocol and blockchain, there is a price for each operation. In order to have anything transferred or executed by the network, you have to consume or burn Gas. Ethereum’s native cryptocurrency is Ether (ETH) and it is used to pay for computation time and transaction fees.The introductory whitepaper was originally published in 2013 by Vitalik Buterin, the founder of Ethereum, the project was crowdfunded during August 2014 by fans all around the world and launched in 2015. Ethereum is developed and maintained by ETHDEV with contributions from minds across the globe. There is an Ecosystem Support Program which is a branch of the Ethereum Foundation focused on supporting projects and entities within the greater Ethereum community to promote the success and growth of the ecosystem. Multiple startups work with the Ethereum blockchain covering areas in: DeFi, NFTs, Ethereum Name Service, Wallets, Scaling, etc.The launch of Ethereum is a process divided into 4 main phases: Frontier, Homestead, Metropolis and Serenity.Ethereum 2.0, also known as Serenity, is the final phase of Ethereum, it aims to solve the decentralized scaling challenge. A naive way to solve Ethereum&#39;s problems would be to make it more centralized. But decentralization is too important, as it gives Ethereum censorship resistance, openness, data privacy and near-unbreakable security.The Eth2 upgrades will make Ethereum scalable, secure, and decentralized. Sharding will make Ethereum more scalable by increasing transactions per second while decreasing the power needed to run a node and validate the chain. The beacon chain will make Ethereum secure by coordinating validators across shards. And staking will lower the barrier to participation, creating a larger – more decentralized – network.The beacon chain will also introduce proof-of-stake to Ethereum. Ethereum is moving to the proof-of-stake (PoS) consensus mechanism from proof-of-work (PoW). This was always the plan as it&#39;s a key part of the community&#39;s strategy to scale Ethereum via the Eth2 upgrades. However, getting PoS right is a big technical challenge and not as straightforward as using PoW to reach consensus across the networkKeep up with Ethereum upgradesFor ETH holders and Dapp users, this has no impact whatsoever, however, for users wishing to get involved, there are ways to participate in Ethereum and future Eth2-related efforts. Get involved in Eth 2.0Blockchain data provided by: Etherchain (Main Source), Blockchair (Backup), and Etherscan (Total Supply only).",
          assetWebsiteUrl: "https://www.ethereum.org/",
          builtOn: "",
          smartContractAddress: "",
          marketCap: marketCap,
          highDay: highDay,
          lowDay: lowDay,
          changePctHour: changePctHour,
          changePctDay: changePctDay,
          changePct24hour: changePct24hour,
          change24hour: change24hour,
          currencyPrice: prices[networkDto.nativeCurrencySymbol],
        )
      )

    let groupedTokens = groupTokensBySymbol(allTokens)
    for symbol, tokens in groupedTokens.pairs:
      # Reset
      enabledNetworkBalance = BalanceDto(
        balance: 0.0,
        currencyBalance: 0.0
      )
      var balancesPerChain = initTable[int, BalanceDto]()
      var visible = false
      
      for token in tokens:
        let balanceForToken = tokenBalances{address}{token.addressAsString()}.getStr
        let chainBalanceForToken = parsefloat(hex2Balance(balanceForToken, token.decimals))
        var enabled = false
        for network in arg.networks:
          if network.chainId == token.chainId:
            enabled = true

        balancesPerChain[token.chainId] = BalanceDto(
          balance: chainBalanceForToken,
          currencyBalance: chainBalanceForToken * prices[token.symbol],
          chainId: token.chainId,
          address: $token.address,
          enabled: enabled,
        )
        if isNetworkEnabledForChainId(arg.networks, token.chainId):
          visible = true
          enabledNetworkBalance.balance += balancesPerChain[token.chainId].balance
          enabledNetworkBalance.currencyBalance += balancesPerChain[token.chainId].currencyBalance

      let tokenDto = getTokenForSymbol(allTokens, symbol)
      var totalTokenBalance: BalanceDto
      totalTokenBalance.balance = toSeq(balancesPerChain.values).map(x => x.balance).foldl(a + b)
      totalTokenBalance.currencyBalance = totalTokenBalance.balance * prices[tokenDto.symbol]
      var marketCap: string = ""
      var highDay: string = ""
      var lowDay: string = ""
      var changePctHour: string = ""
      var changePctDay: string = ""
      var changePct24hour: string = ""
      var change24hour: string = ""
      var description: string = ""
      var assetWebsiteUrl: string = ""
      var builtOn: string = ""
      var smartContractAddress: string = ""

      if(tokenDetails.hasKey(tokenDto.symbol)):
          description = tokenDetails[tokenDto.symbol]["Description"]
          assetWebsiteUrl = tokenDetails[tokenDto.symbol]["AssetWebsiteUrl"]
          builtOn = tokenDetails[tokenDto.symbol]["BuiltOn"]
          smartContractAddress = tokenDetails[tokenDto.symbol]["SmartContractAddress"]

      if(marketValues.hasKey(tokenDto.symbol)):
        marketCap = marketValues[tokenDto.symbol]["MKTCAP"]
        highDay = marketValues[tokenDto.symbol]["HIGHDAY"]
        lowDay = marketValues[tokenDto.symbol]["LOWDAY"]
        changePctHour = marketValues[tokenDto.symbol]["CHANGEPCTHOUR"]
        changePctDay = marketValues[tokenDto.symbol]["CHANGEPCTDAY"]
        changePct24hour = marketValues[tokenDto.symbol]["CHANGEPCT24HOUR"]
        change24hour = marketValues[tokenDto.symbol]["CHANGE24HOUR"]

      let tokenDescription = description.multiReplace([("|", ""),("Facebook",""),("Telegram",""),("Discord",""),("Youtube",""),("YouTube",""),("Instagram",""),("Reddit",""),("Github",""),("GitHub",""),("Whitepaper",""),("Medium",""),("Weibo",""),("LinkedIn",""),("Litepaper",""),("KakaoTalk",""),("BitcoinTalk",""),("Slack",""),("Docs",""),("Kakao",""),("Gitter","")])
      builtTokens.add(WalletTokenDto(
          name: tokenDto.name,
          symbol: tokenDto.symbol,
          decimals: tokenDto.decimals,
          hasIcon: tokenDto.hasIcon,
          color: tokenDto.color,
          isCustom: tokenDto.isCustom,
          totalBalance: totalTokenBalance,
          balancesPerChain: balancesPerChain,
          enabledNetworkBalance: enabledNetworkBalance,
          visible: visible,
          description: tokenDescription,
          assetWebsiteUrl: assetWebsiteUrl,
          builtOn: builtOn,
          smartContractAddress: smartContractAddress,
          marketCap: marketCap,
          highDay: highDay,
          lowDay: lowDay,
          changePctHour: changePctHour,
          changePctDay: changePctDay,
          changePct24hour: changePct24hour,
          change24hour: change24hour,
          currencyPrice: prices[tokenDto.symbol],
        )
      )

    var tokensJArray =  newJArray()
    for wtDto in builtTokens:
      tokensJarray.add(walletTokenDtoToJson(wtDto))
    builtTokensPerAccount[address] = tokensJArray

  arg.finish(builtTokensPerAccount)

