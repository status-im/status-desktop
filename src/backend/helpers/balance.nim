import json, tables, stint, strutils, net, options, chronicles, strformat

import backend/backend

include app_service/common/json_utils

type
  BalanceDto* = object
    rawBalance*: Uint256
    balance*: float64
    address*: string
    chainId*: int
    hasError*: bool

proc `$`*(self: BalanceDto): string =
  result = fmt"""BalanceDto[
    address: {self.address},
    balance: {self.balance},
    chainId: {self.chainId},
    hasError: {self.hasError}
    ]"""

proc getCurrencyBalance*(self: BalanceDto, currencyPrice: float64): float64 =
  return self.balance * currencyPrice

proc toBalanceDto*(jsonObj: JsonNode): BalanceDto =
  result = BalanceDto()

  # Expecting "<nil>" values comming from status-go when the entry is nil
  let rawBalanceStr = jsonObj{"rawBalance"}.getStr
  if not rawBalanceStr.contains("nil"):
    result.rawBalance = rawBalanceStr.parse(Uint256)

  result.balance = jsonObj{"balance"}.getStr.parseFloat()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("hasError", result.hasError)
