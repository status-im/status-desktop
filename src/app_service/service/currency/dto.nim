import json
include  ../../common/json_utils

type
  CurrencyFormatDto* = object
    symbol*: string
    displayDecimals*: uint
    stripTrailingZeroes*: bool

proc newCurrencyFormatDto*(
  symbol: string,
  displayDecimals: uint,
  stripTrailingZeroes: bool,
): CurrencyFormatDto =
  return CurrencyFormatDto(
    symbol: symbol,
    displayDecimals: displayDecimals,
    stripTrailingZeroes: stripTrailingZeroes
  )

proc newCurrencyFormatDto*(symbol: string = ""): CurrencyFormatDto =
  return CurrencyFormatDto(
    symbol: symbol,
    displayDecimals: if len(symbol) == 0: 0 else: 8,
    stripTrailingZeroes: true
  )

proc toCurrencyFormatDto*(jsonObj: JsonNode): CurrencyFormatDto =
  result = CurrencyFormatDto()
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("displayDecimals", result.displayDecimals)
  discard jsonObj.getProp("stripTrailingZeroes", result.stripTrailingZeroes)