import strformat

type
  Item* = ref object
    length: int
    colorIdx: int

proc initItem*(length: int, colorIdx: int): Item =
  result = Item()
  result.length = length
  result.colorIdx = colorIdx

proc `$`*(self: Item): string =
  result = fmt"""ColorHashItem(
    length: {$self.length},
    colorIdx: {$self.colorIdx},
    ]"""

proc length*(self: Item): int {.inline.} =
  self.length

proc colorIdx*(self: Item): int {.inline.} =
  self.colorIdx
