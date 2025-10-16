import json
include  ../../common/json_utils

type
  CurrencyFormatDto* = object
    key*: string
    displayDecimals*: uint
    stripTrailingZeroes*: bool

proc newCurrencyFormatDto*(
  key: string,
  displayDecimals: uint,
  stripTrailingZeroes: bool,
): CurrencyFormatDto =
  return CurrencyFormatDto(
    key: key,
    displayDecimals: displayDecimals,
    stripTrailingZeroes: stripTrailingZeroes
  )

proc newCurrencyFormatDto*(key: string = ""): CurrencyFormatDto =
  return CurrencyFormatDto(
    key: key,
    displayDecimals: if len(key) == 0: 0 else: 8,
    stripTrailingZeroes: true
  )

proc toCurrencyFormatDto*(jsonObj: JsonNode): CurrencyFormatDto =
  result = CurrencyFormatDto()
  discard jsonObj.getProp("key", result.key)
  discard jsonObj.getProp("displayDecimals", result.displayDecimals)
  discard jsonObj.getProp("stripTrailingZeroes", result.stripTrailingZeroes)