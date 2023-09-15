import strformat, stint

import ./currency_amount

type
  Item* = object
    rawBalance*: Uint256
    balance*: CurrencyAmount
    address*: string
    chainId*: int

proc initItem*(
  rawBalance: Uint256,
  balance: CurrencyAmount,
  address: string,
  chainId: int,
): Item =
  result.rawBalance = rawBalance
  result.balance = balance
  result.address = address
  result.chainId = chainId

proc `$`*(self: Item): string =
  result = fmt"""BalanceItem(
    name: {self.balance},
    address: {self.address},
    chainId: {self.chainId},
    ]"""

proc getRawBalance*(self: Item): Uint256 =
  return self.rawBalance

proc getBalance*(self: Item): CurrencyAmount =
  return self.balance

proc getAddress*(self: Item): string =
  return self.address

proc getChainId*(self: Item): int =
  return self.chainId

proc getCurrencyBalance*(self: Item, currencyPrice: CurrencyAmount): CurrencyAmount =
  return newCurrencyAmount(
    self.balance.getAmount() * currencyPrice.getAmount(),
    currencyPrice.getSymbol(),
    currencyPrice.getDisplayDecimals(),
    currencyPrice.isStripTrailingZeroesActive()
  )
