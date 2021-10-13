import strformat

type 
  Item* = object
    name: string
    symbol: string
    value: float
    address: string
    fiatBalance: float
    fiatBalanceDisplay: string

proc initItem*(name, symbol: string, value: float, address: string, fiatBalance: float, fiatBalanceDisplay: string): Item =
  result.name = name
  result.symbol = symbol
  result.value = value
  result.address = address
  result.fiatBalance = fiatBalance
  result.fiatBalanceDisplay = fiatBalanceDisplay

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name}, 
    symbol: {self.symbol},
    value: {self.value},
    address: {self.address}, 
    fiatBalance: {self.fiatBalance}, 
    fiatBalanceDisplay: {self.fiatBalanceDisplay}
    ]"""

proc getName*(self: Item): string = 
  return self.name

proc getSymbol*(self: Item): string = 
  return self.symbol

proc getValue*(self: Item): float = 
  return self.value

proc getAddress*(self: Item): string = 
  return self.address

proc getFiatBalance*(self: Item): float = 
  return self.fiatBalance

proc getFiatBalanceDisplay*(self: Item): string = 
  return self.fiatBalanceDisplay