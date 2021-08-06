import json, strformat

import ../../../../status/chat/[chat]
import ../../../../status/[status]

import location_menu_sub_model, location_menu_sub_item

type 
  MessageSearchLocationMenuItem* = object
    value: string
    title: string
    imageSource: string
    iconName: string
    iconColor: string
    isIdenticon: bool
    subItems: MessageSearchLocationMenuSubModel

proc initMessageSearchLocationMenuItem*(status: Status, 
  value, title, imageSource: string,
  iconName, iconColor: string = "",
  isIdenticon: bool = true): MessageSearchLocationMenuItem =
  result.value = value
  result.title = title
  result.imageSource = imageSource
  result.iconName = iconName
  result.iconColor = iconColor
  result.isIdenticon = isIdenticon
  result.subItems = newMessageSearchLocationMenuSubModel(status)

proc `$`*(self: MessageSearchLocationMenuItem): string =
  result = fmt"""MenuItem(
    value: {self.value}, 
    title: {self.title}, 
    isIdenticon: {self.isIdenticon}, 
    iconName: {self.iconName}, 
    iconColor: {self.iconColor}, 
    imageSource:{self.imageSource}
    subItems:[
      {$self.subItems}
    ]"""

proc getValue*(self: MessageSearchLocationMenuItem): string = 
  return self.value

proc getTitle*(self: MessageSearchLocationMenuItem): string = 
  return self.title

proc getImageSource*(self: MessageSearchLocationMenuItem): string = 
  return self.imageSource

proc getIconName*(self: MessageSearchLocationMenuItem): string = 
  return self.iconName

proc getIconColor*(self: MessageSearchLocationMenuItem): string = 
  return self.iconColor

proc getIsIdenticon*(self: MessageSearchLocationMenuItem): bool = 
  return self.isIdenticon

proc getSubItems*(self: MessageSearchLocationMenuItem): 
  MessageSearchLocationMenuSubModel =
  self.subItems

proc prepareSubItems*(self: MessageSearchLocationMenuItem, chats: seq[Chat],
  isCommunityChannel: bool) =
  self.subItems.prepareItems(chats, isCommunityChannel)

proc getLocationSubItemForChatId*(self: MessageSearchLocationMenuItem, 
  chatId: string, found: var bool): MessageSearchLocationMenuSubItem =
  self.subItems.getLocationSubItemForChatId(chatId, found)

proc toJsonNode*(self: MessageSearchLocationMenuItem): JsonNode =
  result = %* {
    "value": self.value,
    "title": self.title,
    "imageSource": self.imageSource,
    "iconName": self.iconName,
    "iconColor": self.iconColor,
    "isIdenticon": self.isIdenticon
  }
  
 