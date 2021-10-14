import json

include  ../../common/json_utils

import
  web3/ethtypes, json_serialization
from web3/conversions import `$`

type
  Dto* = ref object of RootObj
    name*: string
    chainId*: int
    address*: Address
    symbol*: string
    decimals*: int
    hasIcon* {.dontSerialize.}: bool
    color*: string
    isCustom* {.dontSerialize.}: bool

proc newDto*(
  name: string, chainId: int, address: Address, symbol: string, decimals: int, hasIcon: bool, isCustom: bool = false
): Dto =
  Dto(
    name: name, chainId: chainId, address: address, symbol: symbol, decimals: decimals, hasIcon: hasIcon, isCustom: isCustom
  )

proc toDto*(jsonObj: JsonNode): Dto =
  result = Dto()
  result.isCustom = true
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("color", result.color)
  
proc addressAsString*(self: Dto): string =
  return $self.address