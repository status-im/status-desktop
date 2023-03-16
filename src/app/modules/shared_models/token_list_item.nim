import strformat

type TokenListItemCategory* {.pure.}= enum
  Community = 0,
  Own = 1,
  General = 2

type
  TokenListItem* = object
    key*: string
    name*: string
    symbol*: string
    color*: string
    image*: string
    category*: int

proc initTokenListItem*(
  key: string,
  name: string,
  symbol: string,
  color: string,
  image: string,
  category: int
): TokenListItem =
  result.key = key
  result.symbol = symbol
  result.name = name
  result.color = color
  result.image = image
  result.category = category

proc `$`*(self: TokenListItem): string =
  result = fmt"""TokenListItem(
    key: {self.key},
    name: {self.name},
    color: {self.color},
    symbol: {self.symbol}
    ]"""

proc getKey*(self: TokenListItem): string =
  return self.key

proc getSymbol*(self: TokenListItem): string =
  return self.symbol

proc getName*(self: TokenListItem): string =
  return self.name

proc getColor*(self: TokenListItem): string =
  return self.color

proc getImage*(self: TokenListItem): string =
  return self.image

proc getCategory*(self: TokenListItem): int =
  return self.category
