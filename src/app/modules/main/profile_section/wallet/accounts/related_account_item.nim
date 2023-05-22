import strformat

type
  Item* = object
    name: string
    colorId: string
    emoji: string

proc initItem*(
  name: string = "",
  colorId: string = "",
  emoji: string = "",
): Item =
  result.name = name
  result.colorId = colorId
  result.emoji = emoji

proc `$`*(self: Item): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    colorId: {self.colorId},
    emoji: {self.emoji},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getEmoji*(self: Item): string =
  return self.emoji

proc getColorId*(self: Item): string =
  return self.colorId
