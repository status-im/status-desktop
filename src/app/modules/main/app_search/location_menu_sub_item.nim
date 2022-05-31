import json, strformat, sequtils, sugar
import base_item
import ../../shared_models/[color_hash_item, color_hash_model]

export base_item

type
  SubItem* = ref object of BaseItem
    isUserIcon: bool
    colorId: int
    colorHash: color_hash_model.Model

proc initSubItem*(value, text, image, icon, iconColor: string,
  isUserIcon: bool = false, colorId: int = 0, colorHash: seq[ColorHashSegment] = @[]): SubItem =
  result = SubItem()
  result.setup(value, text, image, icon, iconColor)
  result.isUserIcon = isUserIcon
  result.colorId = colorId
  result.colorHash = color_hash_model.newModel()
  result.colorHash.setItems(map(colorHash, x => color_hash_item.initItem(x.len, x.colorIdx)))

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
    "isUserIcon": self.isUserIcon,
    "colorId": self.colorId,
    "colorHash": self.colorHash.toJson()
  }

proc isUserIcon*(self: SubItem): bool =
  return self.isUserIcon

proc colorId*(self: SubItem): int =
  return self.colorId

proc colorHash*(self: SubItem): color_hash_model.Model =
  return self.colorHash
