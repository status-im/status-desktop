type
  Item* = ref object
    chatId: string
    name: string
    color: string
    icon: string
    sectionId: string
    sectionName: string

proc initItem*(chatId, name, color, icon, sectionId, sectionName: string): Item =
  result = Item()
  result.chatId = chatId
  result.name = name
  result.color = color
  result.icon = icon
  result.sectionId = sectionId
  result.sectionName = sectionName

proc chatId*(self: Item): string =
  self.chatId

proc name*(self: Item): string =
  self.name

proc color*(self: Item): string =
  self.color

proc icon*(self: Item): string =
  self.icon

proc sectionId*(self: Item): string =
  self.sectionId

proc sectionName*(self: Item): string =
  self.sectionName
