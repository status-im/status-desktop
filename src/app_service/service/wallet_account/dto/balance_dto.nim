import json, strformat, strutils

include  app_service/common/json_utils

type BalanceDto* = object
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
  result.balance = jsonObj{"balance"}.getStr.parseFloat()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("hasError", result.hasError)