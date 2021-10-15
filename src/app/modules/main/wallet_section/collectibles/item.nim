import strformat

type 
  Item* = object
    name: string

proc initItem*(name: string): Item =
  result.name = name

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    ]"""

proc getName*(self: Item): string = 
  return self.name