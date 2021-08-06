import json, strformat

type 
  MessageSearchLocationMenuSubItem* = object
    value: string
    text: string
    imageSource: string
    iconName: string
    iconColor: string
    isIdenticon: bool

proc initMessageSearchLocationMenuSubItem*(value, text, imageSource: string, 
  iconName, iconColor: string = "",
  isIdenticon: bool = true): MessageSearchLocationMenuSubItem =
  result.value = value
  result.text = text
  result.imageSource = imageSource
  result.iconName = iconName
  result.iconColor = iconColor
  result.isIdenticon = isIdenticon

proc `$`*(self: MessageSearchLocationMenuSubItem): string =
  result = fmt"""MenuSubItem:
    value: {self.value}, 
    text: {self.text}, 
    isIdenticon: {self.isIdenticon}, 
    iconName: {self.iconName}, 
    iconColor: {self.iconColor}, 
    imageSource:{self.imageSource}"""

proc getValue*(self: MessageSearchLocationMenuSubItem): string = 
  return self.value

proc getText*(self: MessageSearchLocationMenuSubItem): string = 
  return self.text

proc getImageSource*(self: MessageSearchLocationMenuSubItem): string = 
  return self.imageSource

proc getIconName*(self: MessageSearchLocationMenuSubItem): string = 
  return self.iconName

proc getIconColor*(self: MessageSearchLocationMenuSubItem): string = 
  return self.iconColor

proc getIsIdenticon*(self: MessageSearchLocationMenuSubItem): bool = 
  return self.isIdenticon

proc toJsonNode*(self: MessageSearchLocationMenuSubItem): JsonNode =
  result = %* {
    "value": self.value,
    "text": self.text,
    "imageSource": self.imageSource,
    "iconName": self.iconName,
    "iconColor": self.iconColor,
    "isIdenticon": self.isIdenticon
  }

 