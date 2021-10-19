import json, sequtils

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
    visible* {.dontSerialize.}: bool

proc newDto*(
  name: string, chainId: int, address: Address, symbol: string, decimals: int, hasIcon: bool, isCustom: bool = false
): Dto =
  return Dto(
    name: name, chainId: chainId, address: address, symbol: symbol, decimals: decimals, hasIcon: hasIcon, isCustom: isCustom
  )

proc toTokenDto*(jsonObj: JsonNode, activeTokenSymbols: seq[string]): Dto =
  result = Dto()
  result.isCustom = true
  result.visible = false
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("color", result.color)

  if activeTokenSymbols.contains(result.symbol):
    result.visible = true


  
proc addressAsString*(self: Dto): string =
  return $self.address