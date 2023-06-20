import tables, json, strformat, sequtils, sugar, strutils

include  ../../common/json_utils

const WalletTypeDefaultStatusAccount* = ""
const WalletTypeGenerated* = "generated"
const WalletTypeSeed* = "seed"
const WalletTypeWatch* = "watch"
const WalletTypeKey* = "key"

const AccountNonOperable* = "no" # an account is non operable it is not a keycard account and there is no keystore file for it and no keystore file for the address it is derived from
const AccountPartiallyOperable* = "partially" # an account is partially operable if it is not a keycard account and there is created keystore file for the address it is derived from
const AccountFullyOperable* = "fully" # an account is fully operable if it is not a keycard account and there is a keystore file for it

const alwaysVisible = {
  1: @["ETH", "SNT", "DAI"],
  10: @["ETH", "SNT", "DAI"],
  42161: @["ETH", "SNT", "DAI"],
  5: @["ETH", "STT", "DAI"],
  420: @["ETH", "STT", "DAI"],
  421613: @["ETH", "STT", "DAI"],
}.toTable

type BalanceDto* = object
  balance*: float64
  address*: string
  chainId*: int
  hasError*: bool

type
  TokenMarketValuesDto* = object
    marketCap*: float64
    highDay*: float64
    lowDay*: float64
    changePctHour*: float64
    changePctDay*: float64
    changePct24hour*: float64
    change24hour*: float64
    price*: float64
    hasError*: bool

proc newTokenMarketValuesDto*(
  marketCap: float64,
  highDay: float64,
  lowDay: float64,
  changePctHour: float64,
  changePctDay: float64,
  changePct24hour: float64,
  change24hour: float64,
  price: float64,
  hasError: bool
): TokenMarketValuesDto =
  return TokenMarketValuesDto(
    marketCap: marketCap,
    highDay: highDay,
    lowDay: lowDay,
    changePctHour: changePctHour,
    changePctDay: changePctDay,
    changePct24hour: changePct24hour,
    change24hour: change24hour,
    price: price,
    hasError: hasError,
  )

proc toTokenMarketValuesDto*(jsonObj: JsonNode): TokenMarketValuesDto =
  result = TokenMarketValuesDto()
  discard jsonObj.getProp("marketCap", result.marketCap)
  discard jsonObj.getProp("highDay", result.highDay)
  discard jsonObj.getProp("lowDay", result.lowDay)
  discard jsonObj.getProp("changePctHour", result.changePctHour)
  discard jsonObj.getProp("changePctDay", result.changePctDay)
  discard jsonObj.getProp("changePct24hour", result.changePct24hour)
  discard jsonObj.getProp("change24hour", result.change24hour)
  discard jsonObj.getProp("price", result.price)
  discard jsonObj.getProp("hasError", result.hasError)

type
  WalletTokenDto* = object
    name*: string
    symbol*: string
    decimals*: int
    color*: string
    balancesPerChain*: Table[int, BalanceDto]
    description*: string
    assetWebsiteUrl*: string
    builtOn*: string
    marketValuesPerCurrency*: Table[string, TokenMarketValuesDto]

type
  WalletAccountDto* = ref object of RootObj
    name*: string
    address*: string
    mixedcaseAddress*: string
    keyUid*: string
    path*: string
    colorId*: string
    publicKey*: string
    walletType*: string
    isWallet*: bool
    isChat*: bool
    tokens*: seq[WalletTokenDto]
    emoji*: string
    relatedAccounts*: seq[WalletAccountDto]
    ens*: string
    assetsLoading*: bool
    hasBalanceCache*: bool
    hasMarketValuesCache*: bool
    removed*: bool # needs for synchronization
    operable*: string
    createdAt*: int
    position*: int

proc toWalletAccountDto*(jsonObj: JsonNode): WalletAccountDto =
  result = WalletAccountDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("mixedcase-address", result.mixedcaseAddress)
  discard jsonObj.getProp("key-uid", result.keyUid)
  discard jsonObj.getProp("path", result.path)
  discard jsonObj.getProp("colorId", result.colorId)
  result.colorId = result.colorId.toUpper() # to match `preDefinedWalletAccountColors` on the qml side
  discard jsonObj.getProp("wallet", result.isWallet)
  discard jsonObj.getProp("chat", result.isChat)
  discard jsonObj.getProp("public-key", result.publicKey)
  discard jsonObj.getProp("type", result.walletType)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("removed", result.removed)
  discard jsonObj.getProp("operable", result.operable)
  discard jsonObj.getProp("createdAt", result.createdAt)
  discard jsonObj.getProp("position", result.position)
  result.assetsLoading = true
  result.hasBalanceCache = false
  result.hasMarketValuesCache = false

proc `$`*(self: WalletAccountDto): string =
  result = fmt"""WalletAccountDto[
    name: {self.name},
    address: {self.address},
    mixedcaseAddress: {self.mixedcaseAddress},
    keyUid: {self.keyUid},
    path: {self.path},
    colorId: {self.colorId},
    publicKey: {self.publicKey},
    walletType: {self.walletType},
    isChat: {self.isChat},
    emoji: {self.emoji},
    hasBalanceCache: {self.hasBalanceCache},
    hasMarketValuesCache: {self.hasMarketValuesCache},
    removed: {self.removed}
    operable: {self.operable}
    ]"""

proc getCurrencyBalance*(self: BalanceDto, currencyPrice: float64): float64 =
  return self.balance * currencyPrice

proc copyToken*(self: WalletTokenDto): WalletTokenDto =
  result = WalletTokenDto()
  result.name = self.name
  result.symbol = self.symbol
  result.decimals = self.decimals
  result.color = self.color
  result.description = self.description
  result.assetWebsiteUrl = self.assetWebsiteUrl
  result.builtOn = self.builtOn

  result.balancesPerChain = initTable[int, BalanceDto]()
  for chainId, balanceDto in self.balancesPerChain:
    result.balancesPerChain[chainId] = balanceDto
  result.marketValuesPerCurrency = initTable[string, TokenMarketValuesDto]()
  for chainId, tokenMarketValuesDto in self.marketValuesPerCurrency:
    result.marketValuesPerCurrency[chainId] = tokenMarketValuesDto

proc getAddress*(self: WalletTokenDto): string =
  for balance in self.balancesPerChain.values:
    return balance.address

  return ""

proc getTotalBalanceOfSupportedChains*(self: WalletTokenDto): float64 =
  var sum = 0.0
  for chainId, balanceDto in self.balancesPerChain:
    sum += balanceDto.balance

  return sum

proc getBalances*(self: WalletTokenDto, chainIds: seq[int]): seq[BalanceDto] =
  for chainId in chainIds:
    if self.balancesPerChain.hasKey(chainId):
      result.add(self.balancesPerChain[chainId])

proc getBalance*(self: WalletTokenDto, chainIds: seq[int]): float64 =
  var sum = 0.0
  for chainId in chainIds:
    if self.balancesPerChain.hasKey(chainId):
      sum += self.balancesPerChain[chainId].balance
  
  return sum

proc getCurrencyBalance*(self: WalletTokenDto, chainIds: seq[int], currency: string): float64 =
  var sum = 0.0
  let price = if self.marketValuesPerCurrency.hasKey(currency): self.marketValuesPerCurrency[currency].price else: 0.0
  for chainId in chainIds:
    if self.balancesPerChain.hasKey(chainId):
      sum += self.balancesPerChain[chainId].getCurrencyBalance(price)
  
  return sum

proc getVisibleForNetwork*(self: WalletTokenDto, chainIds: seq[int]): bool =
  for chainId in chainIds:
    if self.balancesPerChain.hasKey(chainId):
      return true
  
  return false

proc getVisibleForNetworkWithPositiveBalance*(self: WalletTokenDto, chainIds: seq[int]): bool =
  for chainId in chainIds:
    if alwaysVisible.hasKey(chainId) and self.symbol in alwaysVisible[chainId]:
      return true

    if self.balancesPerChain.hasKey(chainId) and self.balancesPerChain[chainId].balance > 0:
      return true
  
  return false

proc getCurrencyBalance*(self: WalletAccountDto, chainIds: seq[int], currency: string): float64 =
  return self.tokens.map(t => t.getCurrencyBalance(chainIds, currency)).foldl(a + b, 0.0)

proc toBalanceDto*(jsonObj: JsonNode): BalanceDto =
  result = BalanceDto()
  result.balance = jsonObj{"balance"}.getStr.parseFloat()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("hasError", result.hasError)

proc toWalletTokenDto*(jsonObj: JsonNode): WalletTokenDto =
  result = WalletTokenDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("assetWebsiteUrl", result.assetWebsiteUrl)
  discard jsonObj.getProp("builtOn", result.builtOn)

  var marketValuesPerCurrencyObj: JsonNode
  if(jsonObj.getProp("marketValuesPerCurrency", marketValuesPerCurrencyObj)):
    for currency, marketValuesObj in marketValuesPerCurrencyObj:
      result.marketValuesPerCurrency[currency.toUpperAscii()] = marketValuesObj.toTokenMarketValuesDto()

  var balancesPerChainObj: JsonNode
  if(jsonObj.getProp("balancesPerChain", balancesPerChainObj)):
    for chainId, balanceObj in balancesPerChainObj:
      result.balancesPerChain[parseInt(chainId)] = toBalanceDto(balanceObj)
