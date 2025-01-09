import stew/shims/strformat

type Item* = ref object
  segmentLength: int
  colorId: int

proc initItem*(segmentLength: int, colorId: int): Item =
  result = Item()
  result.segmentLength = segmentLength
  result.colorId = colorId

proc `$`*(self: Item): string =
  result =
    fmt"""ColorHashItem(
    segmentLength: {$self.segmentLength},
    colorId: {$self.colorId},
    ]"""

proc segmentLength*(self: Item): int {.inline.} =
  self.segmentLength

proc colorId*(self: Item): int {.inline.} =
  self.colorId
