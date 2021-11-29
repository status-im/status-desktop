import json, strformat

type 
  Item* = object
    sectionType: int
    id: string
    name: string
    image: string
    icon: string
    color: string
    mentionsCount: int
    unviewedMessagesCount: int

proc initItem*(id: string, sectionType: int, name, image = "", icon = "", color = "",
  mentionsCount:int = 0, unviewedMessagesCount: int = 0): Item =
  result.id = id
  result.sectionType = sectionType
  result.name = name
  result.image = image
  result.icon = icon
  result.color = color
  result.mentionsCount = mentionsCount
  result.unviewedMessagesCount = unviewedMessagesCount

proc `$`*(self: Item): string =
  result = fmt"""MainModuleItem(
    id: {self.id}, 
    sectionType: {self.sectionType},
    name: {self.name}, 
    image: {self.image},
    icon: {self.icon},
    color: {self.color}, 
    mentionsCount: {self.mentionsCount}, 
    unviewedMessagesCount:{self.unviewedMessagesCount}
    ]"""

proc getId*(self: Item): string = 
  return self.id

proc getSectionType*(self: Item): int = 
  return self.sectionType

proc getName*(self: Item): string = 
  return self.name

proc getImage*(self: Item): string = 
  return self.image

proc getIcon*(self: Item): string = 
  return self.icon

proc getColor*(self: Item): string = 
  return self.color

proc getMentionsCount*(self: Item): int = 
  return self.mentionsCount

proc getUnviewedMessagesCount*(self: Item): int = 
  return self.unviewedMessagesCount
