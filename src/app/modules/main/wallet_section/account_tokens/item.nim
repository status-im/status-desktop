import strformat

type
  Item* = object
    name: string
    symbol: string
    balance: float
    address: string
    currencyBalance: float

proc initItem*(name, symbol: string, balance: float, address: string, currencyBalance: float): Item =
  result.name = name
  result.symbol = symbol
  result.balance = balance
  result.address = address
  result.currencyBalance = currencyBalance

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    symbol: {self.symbol},
    balance: {self.balance},
    address: {self.address},
    currencyBalance: {self.currencyBalance},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getSymbol*(self: Item): string =
  return self.symbol

proc getBalance*(self: Item): float =
  return self.balance

proc getAddress*(self: Item): string =
  return self.address

proc getCurrencyBalance*(self: Item): float =
  return self.currencyBalance
