import json
include  ../../common/json_utils

type
  CurrencyFormatDto* = object
    key: string
    symbol: string
    displayDecimals: uint
    stripTrailingZeroes: bool

proc key*(self: CurrencyFormatDto): string = return self.key
proc symbol*(self: CurrencyFormatDto): string = return self.symbol
proc displayDecimals*(self: CurrencyFormatDto): uint = return self.displayDecimals
proc stripTrailingZeroes*(self: CurrencyFormatDto): bool = return self.stripTrailingZeroes

proc newCurrencyFormatDto*(key: string = "", symbol: string = ""): CurrencyFormatDto =
  return CurrencyFormatDto(
    key: key,
    symbol: symbol,
    displayDecimals: if len(key) == 0: 0 else: 8, # not sure about this logic, but it was like this in the old code
    stripTrailingZeroes: true
  )

proc toCurrencyFormatDto*(jsonObj: JsonNode): CurrencyFormatDto =
  result = CurrencyFormatDto()
  discard jsonObj.getProp("key", result.key)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("displayDecimals", result.displayDecimals)
  discard jsonObj.getProp("stripTrailingZeroes", result.stripTrailingZeroes)