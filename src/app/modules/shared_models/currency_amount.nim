import nimqml, stew/shims/strformat, json

include app_service/common/json_utils

QtObject:
  type CurrencyAmount* = ref object of QObject
    amount: float64
    symbol: string
    displayDecimals: int
    stripTrailingZeroes: bool

  proc setup(self: CurrencyAmount)
  proc delete*(self: CurrencyAmount)
  proc newCurrencyAmount*(
    amount: float64,
    symbol: string,
    displayDecimals: int,
    stripTrailingZeroes: bool,
  ): CurrencyAmount =
    new(result, delete)
    result.setup
    result.amount = amount
    result.symbol = symbol
    result.displayDecimals = displayDecimals
    result.stripTrailingZeroes = stripTrailingZeroes

  proc newCurrencyAmount*: CurrencyAmount =
    result = newCurrencyAmount(0.0, "", 0, true)

  proc set*(self: var CurrencyAmount, other: CurrencyAmount) =
    self.amount = other.amount
    self.symbol = other.symbol
    self.displayDecimals = other.displayDecimals
    self.stripTrailingZeroes = other.stripTrailingZeroes

  proc `==`*(self: CurrencyAmount, other: CurrencyAmount): bool =
    if self.isNil or other.isNil: return false

    return self.amount == other.amount and
      self.symbol == other.symbol and
      self.displayDecimals == other.displayDecimals and
      self.stripTrailingZeroes == other.stripTrailingZeroes

  proc `$`*(self: CurrencyAmount): string =
    result = fmt"""CurrencyAmount(
      amount: {self.amount},
      symbol: {self.symbol},
      displayDecimals: {self.displayDecimals},
      stripTrailingZeroes: {self.stripTrailingZeroes}
      )"""

  proc amountChanged*(self: CurrencyAmount) {.signal.}
  proc getAmount*(self: CurrencyAmount): float {.slot.} =
    return self.amount
  proc setAmount*(self: CurrencyAmount, value: float) {.slot.} =
    if self.amount != value:
      self.amount = value
      self.amountChanged()
  QtProperty[float] amount:
    read = getAmount
    write = setAmount
    notify = amountChanged

  proc symbolChanged*(self: CurrencyAmount) {.signal.}
  proc getSymbol*(self: CurrencyAmount): string {.slot.} =
    return self.symbol
  proc setSymbol*(self: CurrencyAmount, value: string) {.slot.} =
    if self.symbol != value:
      self.symbol = value
      self.symbolChanged()
  QtProperty[string] symbol:
    read = getSymbol
    write = setSymbol
    notify = symbolChanged

  proc displayDecimalsChanged*(self: CurrencyAmount) {.signal.}
  proc getDisplayDecimals*(self: CurrencyAmount): int {.slot.} =
    return self.displayDecimals
  proc setDisplayDecimals*(self: CurrencyAmount, value: int) {.slot.} =
    if self.displayDecimals != value:
      self.displayDecimals = value
      self.displayDecimalsChanged()
  QtProperty[int] displayDecimals:
    read = getDisplayDecimals
    write = setDisplayDecimals
    notify = displayDecimalsChanged

  proc stripTrailingZeroesChanged*(self: CurrencyAmount) {.signal.}
  proc isStripTrailingZeroesActive*(self: CurrencyAmount): bool {.slot.} =
    return self.stripTrailingZeroes
  proc setStripTrailingZeroes*(self: CurrencyAmount, value: bool) {.slot.} =
    if self.stripTrailingZeroes != value:
      self.stripTrailingZeroes = value
      self.stripTrailingZeroesChanged()
  QtProperty[bool] stripTrailingZeroes:
    read = isStripTrailingZeroesActive
    write = setStripTrailingZeroes
    notify = stripTrailingZeroesChanged

  proc update*(self: CurrencyAmount, other: CurrencyAmount) =
    ## Update this CurrencyAmount from another, calling setters for changed properties
    ## This ensures proper signal emission for fine-grained QML updates
    if self.isNil or other.isNil: return
    
    if self.amount != other.amount:
      self.setAmount(other.amount)
    if self.symbol != other.symbol:
      self.setSymbol(other.symbol)
    if self.displayDecimals != other.displayDecimals:
      self.setDisplayDecimals(other.displayDecimals)
    if self.stripTrailingZeroes != other.stripTrailingZeroes:
      self.setStripTrailingZeroes(other.stripTrailingZeroes)

  # Needed to expose object to QML, see issue #8913
  proc toJsonNode*(self: CurrencyAmount): JsonNode =
    result = %* {
      "amount": self.amount,
      "symbol": self.symbol,
      "displayDecimals": self.displayDecimals,
      "stripTrailingZeroes": self.stripTrailingZeroes
    }

  # Needed by profile showcase
  proc toCurrencyAmount*(jsonObj: JsonNode): CurrencyAmount =
    new(result, delete)
    result.setup
    discard jsonObj.getProp("amount", result.amount)
    discard jsonObj.getProp("symbol", result.symbol)
    discard jsonObj.getProp("displayDecimals", result.displayDecimals)
    discard jsonObj.getProp("stripTrailingZeroes", result.stripTrailingZeroes)

  proc setup(self: CurrencyAmount) =
    self.QObject.setup

  proc delete*(self: CurrencyAmount) =
    self.QObject.delete

