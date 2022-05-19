import json

include  ../../common/json_utils

import
  web3/ethtypes, json_serialization
from web3/conversions import `$`

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

proc newTokenDto*(
  name: string, chainId: int, address: Address, symbol: string, decimals: int, hasIcon: bool, isCustom: bool = false
): TokenDto =
  return TokenDto(
    name: name, chainId: chainId, address: address, symbol: symbol, decimals: decimals, hasIcon: hasIcon, isCustom: isCustom
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

  result.isVisible = isVisible

proc addressAsString*(self: TokenDto): string =
  return $self.address