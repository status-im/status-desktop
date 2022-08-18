import strformat

type
  Item* = object
    name: string
    address: string
    favourite: bool

proc initItem*(
  name: string,
  address: string,
  favourite: bool
): Item =
  result.name = name
  result.address = address
  result.favourite = favourite

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    address: {self.address},
    favourite: {self.favourite},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getAddress*(self: Item): string =
  return self.address

proc getFavourite*(self: Item): bool =
  return self.favourite
