import tables, json, strformat, sequtils, sugar, stint, strutils

import balance_dto

include  app_service/common/json_utils

export balance_dto

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


# Get address from goside needed for community use case
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
    communityId: string

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
      result.marketValuesPerCurrency[currency.toUpperAscii()] = toTokenMarketValuesDto(marketValuesObj)

  var balancesPerChainObj: JsonNode
  if(jsonObj.getProp("balancesPerChain", balancesPerChainObj)):
    for chainId, balanceObj in balancesPerChainObj:
      result.balancesPerChain[parseInt(chainId)] = toBalanceDto(balanceObj)

proc `$`*(self: TokenMarketValuesDto): string =
  result = fmt"""TokenMarketValuesDto[
    marketCap: {self.marketCap},
    highDay: {self.highDay},
    lowDay: {self.lowDay},
    changePctHour: {self.changePctHour},
    changePctDay: {self.changePctDay},
    changePct24hour: {self.changePct24hour},
    change24hour: {self.change24hour},
    price: {self.price},
    hasError: {self.hasError}
    ]"""

proc `$`*(self: WalletTokenDto): string =
  result = fmt"""WalletTokenDto[
    name: {self.name},
    symbol: {self.symbol},
    decimals: {self.decimals},
    color: {self.color},
    description: {self.description},
    assetWebsiteUrl: {self.assetWebsiteUrl},
    builtOn: {self.builtOn},
    balancesPerChain:
    """
  for chain, balance in self.balancesPerChain:
    result &= fmt"""
      [{chain}]:({$balance})
      """

  result &= fmt"""
    marketValuesPerCurrency:
  """
  for currency, values in self.marketValuesPerCurrency:
    result &= fmt"""
      [{currency}]:({$values})
      """
  result &= """
    ]"""

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

proc getRawBalance*(self: WalletTokenDto, chainIds: seq[int]): UInt256 =
  var sum = stint.u256(0)
  for chainId in chainIds:
    if self.balancesPerChain.hasKey(chainId):
      sum += self.balancesPerChain[chainId].rawBalance
  return sum

proc getCurrencyBalance*(self: WalletTokenDto, chainIds: seq[int], currency: string): float64 =
  var sum = 0.0
  let price = if self.marketValuesPerCurrency.hasKey(currency): self.marketValuesPerCurrency[currency].price else: 0.0
  for chainId in chainIds:
    if self.balancesPerChain.hasKey(chainId):
      sum += self.balancesPerChain[chainId].getCurrencyBalance(price)
  return sum


