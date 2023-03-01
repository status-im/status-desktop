import strformat

type
  Item* = object
    name: string
    address: string
    ens: string
    favourite: bool
    chainShortNames: string
    isTest: bool

proc initItem*(
  name: string,
  address: string,
  favourite: bool,
  ens: string,
  chainShortNames: string,
  isTest: bool
): Item =
  result.name = name
  result.address = address
  result.favourite = favourite
  result.ens = ens
  result.chainShortNames = chainShortNames
  result.isTest = isTest

proc `$`*(self: Item): string =
  result = fmt"""SavedAddressItem(
    name: {self.name},
    address: {self.address},
    favourite: {self.favourite},
    ens: {self.ens},
    chainShortNames: {self.chainShortNames},
    isTest: {self.isTest},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getEns*(self: Item): string =
  return self.ens

proc getAddress*(self: Item): string =
  return self.address

proc getFavourite*(self: Item): bool =
  return self.favourite

proc getChainShortNames*(self: Item): string =
  return self.chainShortNames

proc getIsTest*(self: Item): bool =
  return self.isTest
