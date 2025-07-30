type
  Item* = ref object
    chatId: string
    name: string
    color: string
    colorId: int
    icon: string
    sectionId: string
    sectionName: string
    colorHash: string
    emoji: string
    chatType: int

proc initItem*(chatId, name, color: string, colorId: int, icon, colorHash, sectionId, sectionName, emoji: string, chatType: int): Item =
  result = Item()
  result.chatId = chatId
  result.name = name
  result.color = color
  result.colorId = colorId
  result.icon = icon
  result.colorHash = colorHash
  result.sectionId = sectionId
  result.sectionName = sectionName
  result.emoji = emoji
  result.chatType = chatType

proc chatId*(self: Item): string =
  self.chatId

proc name*(self: Item): string =
  self.name

proc color*(self: Item): string =
  self.color

proc colorId*(self: Item): int =
  self.colorId

proc icon*(self: Item): string =
  self.icon

proc colorHash*(self: Item): string =
  self.colorHash

proc sectionId*(self: Item): string =
  self.sectionId

proc sectionName*(self: Item): string =
  self.sectionName

proc emoji*(self: Item): string =
  self.emoji

proc chatType*(self: Item): int =
  self.chatType
