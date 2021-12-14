import strformat

type 
  Item* = object
    name: string
    address: string

proc initItem*(
  name: string,
  address: string,
): Item =
  result.name = name
  result.address = address

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name}, 
    address: {self.address},
    ]"""

proc getName*(self: Item): string = 
  return self.name

proc getAddress*(self: Item): string = 
  return self.address
