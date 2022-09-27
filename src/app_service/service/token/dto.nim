import json

include  ../../common/json_utils

import
  web3/ethtypes, json_serialization
from web3/conversions import `$`

const WEEKLY_TIME_RANGE* = 0
const MONTHLY_TIME_RANGE* = 1
const HALF_YEARLY_TIME_RANGE* = 2
const YEARLY_TIME_RANGE* = 3
const ALL_TIME_RANGE* = 4

type
  TokenDto* = ref object of RootObj
    name*: string
    chainId*: int
    address*: Address
    symbol*: string
    decimals*: int
    hasIcon* {.dontSerialize.}: bool
    color*: string
    isCustom* {.dontSerialize.}: bool
    isVisible* {.dontSerialize.}: bool
    description* :string
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

proc newTokenDto*(
  name: string,
  chainId: int,
  address: Address,
  symbol: string,
  decimals: int,
  hasIcon: bool,
  isCustom: bool = false,
  description: string = "",
  assetWebsiteUrl: string = "",
  builtOn: string = "",
  smartContractAddress: string = "",
  marketCap: string = "",
  highDay: string = "",
  lowDay: string = "",
  changePctHour: string = "",
  changePctDay: string = "",
  changePct24hour: string = "",
  change24hour: string = "",
): TokenDto =
  return TokenDto(
    name: name,
    chainId: chainId,
    address: address,
    symbol: symbol,
    decimals: decimals,
    hasIcon: hasIcon,
    isCustom: isCustom,
    description: description,
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
  )

proc toTokenDto*(jsonObj: JsonNode, isVisible: bool, hasIcon: bool = false, isCustom: bool = true): TokenDto =
  result = TokenDto()
  result.isCustom = isCustom
  result.hasIcon = hasIcon

  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("color", result.color)
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

  result.isVisible = isVisible

proc addressAsString*(self: TokenDto): string =
  return $self.address
