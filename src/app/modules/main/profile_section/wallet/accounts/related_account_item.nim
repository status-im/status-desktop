import strformat

type
  Item* = object
    name: string
    color: string
    emoji: string

proc initItem*(
  name: string = "",
  color: string = "",
  emoji: string = "",
): Item =
  result.name = name
  result.color = color
  result.emoji = emoji

proc `$`*(self: Item): string =
  result = fmt"""WalletAccountItem(
    name: {self.name},
    color: {self.color},
    emoji: {self.emoji},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getEmoji*(self: Item): string =
  return self.emoji

proc getColor*(self: Item): string =
  return self.color