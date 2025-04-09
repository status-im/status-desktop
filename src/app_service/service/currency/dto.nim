import json
include  ../../common/json_utils

type
  CurrencyFormatDto* = object
    id*: string # refers a grouped token key or currency code
    displayDecimals*: uint
    stripTrailingZeroes*: bool

proc newCurrencyFormatDto*(
  id: string,
  displayDecimals: uint,
  stripTrailingZeroes: bool,
): CurrencyFormatDto =
  return CurrencyFormatDto(
    id: id,
    displayDecimals: displayDecimals,
    stripTrailingZeroes: stripTrailingZeroes
  )

proc newCurrencyFormatDto*(id: string = ""): CurrencyFormatDto =
  return CurrencyFormatDto(
    id: id,
    displayDecimals: if len(id) == 0: 0 else: 8,
    stripTrailingZeroes: true
  )

proc toCurrencyFormatDto*(jsonObj: JsonNode): CurrencyFormatDto =
  result = CurrencyFormatDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("displayDecimals", result.displayDecimals)
  discard jsonObj.getProp("stripTrailingZeroes", result.stripTrailingZeroes)