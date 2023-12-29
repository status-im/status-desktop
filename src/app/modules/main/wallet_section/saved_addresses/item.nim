import strformat

type
  Item* = object
    name: string
    address: string
    ens: string
    colorId: string
    favourite: bool
    chainShortNames: string
    isTest: bool

proc initItem*(
  name: string,
  address: string,
  ens: string,
  colorId: string,
  favourite: bool,
  chainShortNames: string,
  isTest: bool
): Item =
  result.name = name
  result.address = address
  result.favourite = favourite
  result.ens = ens
  result.colorId = colorId
  result.chainShortNames = chainShortNames
  result.isTest = isTest

proc `$`*(self: Item): string =
  result = fmt"""SavedAddressItem(
    name: {self.name},
    address: {self.address},
    ens: {self.ens},
    colorId: {self.colorId},
    favourite: {self.favourite},
    chainShortNames: {self.chainShortNames},
    isTest: {self.isTest},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getEns*(self: Item): string =
  return self.ens

proc getAddress*(self: Item): string =
  return self.address

proc getColorId*(self: Item): string =
  return self.colorId

proc getFavourite*(self: Item): bool =
  return self.favourite

proc getChainShortNames*(self: Item): string =
  return self.chainShortNames

proc getIsTest*(self: Item): bool =
  return self.isTest
