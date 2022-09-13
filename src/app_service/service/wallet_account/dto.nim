import tables, json, sequtils, sugar, strutils

include  ../../common/json_utils

const WalletTypeDefaultStatusAccount* = ""
const WalletTypeGenerated* = "generated"
const WalletTypeSeed* = "seed"
const WalletTypeWatch* = "watch"
const WalletTypeKey* = "key"

type BalanceDto* = object
  balance*: float64
  currencyBalance*: float64
  address*: string
  chainId*: int

type
  WalletTokenDto* = object
    name*: string
    symbol*: string
    decimals*: int
    hasIcon*: bool
    color*: string
    isCustom*: bool
    totalBalance*: BalanceDto
    enabledNetworkBalance*: BalanceDto
    balancesPerChain*: Table[int, BalanceDto]
    visible*: bool
    description*: string
    assetWebsiteUrl*: string
    builtOn*: string
    smartContractAddress*: string
    marketCap*: string
    highDay*: string
    lowDay*: string
    changePctHour*: string
    changePctDay*: string
    changePct24hour*: string
    change24hour*: string
    currencyPrice*: float64

type
  WalletAccountDto* = ref object of RootObj
    name*: string
    address*: string
    mixedcaseAddress*: string
    keyUid*: string
    path*: string
    color*: string
    publicKey*: string
    walletType*: string
    isWallet*: bool
    isChat*: bool
    tokens*: seq[WalletTokenDto]
    emoji*: string
    derivedfrom*: string
    relatedAccounts*: seq[WalletAccountDto]

proc newDto*(
  name: string,
  address: string,
  path: string,
  color: string,
  publicKey: string,
  walletType: string,
  isWallet: bool,
  isChat: bool,
  emoji: string,
  derivedfrom: string,
  relatedAccounts: seq[WalletAccountDto]
): WalletAccountDto =
  return WalletAccountDto(
    name: name,
    address: address,
    path: path,
    color: color,
    publicKey: publicKey,
    walletType: walletType,
    isWallet: isWallet,
    isChat: isChat,
    emoji: emoji,
    derivedfrom: derivedfrom,
    relatedAccounts: relatedAccounts
  )

proc toWalletAccountDto*(jsonObj: JsonNode): WalletAccountDto =
  result = WalletAccountDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("mixedcase-address", result.mixedcaseAddress)
  discard jsonObj.getProp("key-uid", result.keyUid)
  discard jsonObj.getProp("path", result.path)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("wallet", result.isWallet)
  discard jsonObj.getProp("chat", result.isChat)
  discard jsonObj.getProp("public-key", result.publicKey)
  discard jsonObj.getProp("type", result.walletType)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("derived-from", result.derivedfrom)

proc getCurrencyBalance*(self: WalletAccountDto): float64 =
  return self.tokens.map(t => t.enabledNetworkBalance.currencyBalance).foldl(a + b, 0.0)

proc toBalanceDto*(jsonObj: JsonNode): BalanceDto =
  result = BalanceDto()
  discard jsonObj.getProp("balance", result.balance)
  discard jsonObj.getProp("currencyBalance", result.currencyBalance)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("chainId", result.chainId)

proc toWalletTokenDto*(jsonObj: JsonNode): WalletTokenDto =
  result = WalletTokenDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("hasIcon", result.hasIcon)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("isCustom", result.isCustom)
  discard jsonObj.getProp("visible", result.visible)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("assetWebsiteUrl", result.assetWebsiteUrl)
  discard jsonObj.getProp("builtOn", result.builtOn)
  discard jsonObj.getProp("smartContractAddress", result.smartContractAddress)
  discard jsonObj.getProp("marketCap", result.marketCap)
  discard jsonObj.getProp("highDay", result.highDay)
  discard jsonObj.getProp("lowDay", result.lowDay)
  discard jsonObj.getProp("changePctHour", result.changePctHour)
  discard jsonObj.getProp("changePctDay", result.changePctDay)
  discard jsonObj.getProp("changePct24hour", result.changePct24hour)
  discard jsonObj.getProp("change24hour", result.change24hour)
  discard jsonObj.getProp("currencyPrice", result.currencyPrice)

  var totalBalanceObj: JsonNode
  if(jsonObj.getProp("totalBalance", totalBalanceObj)):
    result.totalBalance = toBalanceDto(totalBalanceObj)
  
  var enabledNetworkBalanceObj: JsonNode
  if(jsonObj.getProp("enabledNetworkBalance", enabledNetworkBalanceObj)):
    result.enabledNetworkBalance = toBalanceDto(enabledNetworkBalanceObj)
    
  var balancesPerChainObj: JsonNode
  if(jsonObj.getProp("balancesPerChain", balancesPerChainObj)):
    for chainId, balanceObj in balancesPerChainObj:
      result.balancesPerChain[parseInt(chainId)] = toBalanceDto(balanceObj)

proc walletTokenDtoToJson*(dto: WalletTokenDto): JsonNode =
  var balancesPerChainJsonObj = newJObject()
  for k, v in dto.balancesPerChain.pairs:
    balancesPerChainJsonObj[$k] = %* v

  result = %* {
    "name": dto.name,
    "symbol": dto.symbol,
    "decimals": dto.decimals,
    "hasIcon": dto.hasIcon,
    "color": dto.color,
    "isCustom": dto.isCustom,
    "totalBalance": %* dto.totalBalance,
    "enabledNetworkBalance": %* dto.enabledNetworkBalance,
    "balancesPerChain": balancesPerChainJsonObj,
    "visible": dto.visible,
    "description": dto.description,
    "assetWebsiteUrl": dto.assetWebsiteUrl,
    "builtOn": dto.builtOn,
    "smartContractAddress": dto.smartContractAddress,
    "marketCap": dto.marketCap,
    "highDay": dto.highDay,
    "lowDay": dto.lowDay,
    "changePctHour": dto.changePctHour,
    "changePctDay": dto.changePctDay,
    "changePct24hour": dto.changePct24hour,
    "change24hour": dto.change24hour,
    "currencyPrice": dto.currencyPrice,
  }
