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
    communityId*: string
    supply*: string
    infiniteSupply*: bool

proc initTokenListItem*(
  key: string,
  name: string,
  symbol: string,
  color: string,
  image: string,
  category: int,
  communityId: string = "",
  supply: string = "1",
  infiniteSupply: bool = true,
): TokenListItem =
  result.key = key
  result.symbol = symbol
  result.name = name
  result.color = color
  result.image = image
  result.category = category
  result.communityId = communityId
  result.supply = supply
  result.infiniteSupply = infiniteSupply

proc `$`*(self: TokenListItem): string =
  result = fmt"""TokenListItem(
    key: {self.key},
    name: {self.name},
    color: {self.color},
    symbol: {self.symbol},
    category: {self.category},
    communityId: {self.communityId},
    supply: {self.supply},
    infiniteSupply: {self.infiniteSupply},
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

proc getCommunityId*(self: TokenListItem): string =
  return self.communityId

proc getSupply*(self: TokenListItem): string =
  return self.supply

proc getInfiniteSupply*(self: TokenListItem): bool =
  return self.infiniteSupply
