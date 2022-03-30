import json, strformat
import base_item

export base_item

type
  SubItem* = ref object of BaseItem

proc initSubItem*(value, text, image, icon, iconColor: string): SubItem =
  result = SubItem()
  result.setup(value, text, image, icon, iconColor)

proc delete*(self: SubItem) =
  self.BaseItem.delete

proc `$`*(self: SubItem): string =
  result = fmt"""SearchMenuSubItem(
    value: {self.value},
    text: {self.text},
    imageSource: {self.image},
    iconName: {self.icon},
    iconColor: {self.iconColor},
    ]"""

proc toJsonNode*(self: SubItem): JsonNode =
  result = %* {
    "value": self.value,
    "text": self.text,
    "imageSource": self.image,
    "iconName": self.icon,
    "iconColor": self.iconColor,
  }
