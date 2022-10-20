import strformat

type
  Item* = object
    name: string
    address: string
    ens: string
    favourite: bool

proc initItem*(
  name: string,
  address: string,
  favourite: bool,
  ens: string
): Item =
  result.name = name
  result.address = address
  result.favourite = favourite
  result.ens = ens

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    address: {self.address},
    favourite: {self.favourite},
    ens: {self.ens},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getEns*(self: Item): string =
  return self.ens

proc getAddress*(self: Item): string =
  return self.address

proc getFavourite*(self: Item): bool =
  return self.favourite
