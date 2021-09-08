import NimQml, Tables, strutils

import status/chat/[chat]
import status/[status]

import location_menu_item, location_menu_sub_item, constants

type
  MessageSearchLocationMenuModelRole {.pure.} = enum
    Value = UserRole + 1
    Title
    ImageSource
    IconName
    IconColor
    IsIdenticon
    SubItems

QtObject:
  type
    MessageSearchLocationMenuModel* = ref object of QAbstractListModel
      items: seq[MessageSearchLocationMenuItem]

  proc delete(self: MessageSearchLocationMenuModel) =
    self.QAbstractListModel.delete

  proc setup(self: MessageSearchLocationMenuModel) =
    self.QAbstractListModel.setup

  proc newMessageSearchLocationMenuModel*(): MessageSearchLocationMenuModel =
    new(result, delete)
    result.setup()

  method rowCount(self: MessageSearchLocationMenuModel, 
    index: QModelIndex = nil): int =

    return self.items.len

  method roleNames(self: MessageSearchLocationMenuModel): Table[int, string] =
    {
      MessageSearchLocationMenuModelRole.Value.int:"value",
      MessageSearchLocationMenuModelRole.Title.int:"title",
      MessageSearchLocationMenuModelRole.ImageSource.int:"imageSource",
      MessageSearchLocationMenuModelRole.IconName.int:"iconName",
      MessageSearchLocationMenuModelRole.IconColor.int:"iconColor",
      MessageSearchLocationMenuModelRole.IsIdenticon.int:"isIdenticon",
      MessageSearchLocationMenuModelRole.SubItems.int:"subItems"
    }.toTable

  method data(self: MessageSearchLocationMenuModel, index: QModelIndex, 
    role: int): QVariant =

    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.MessageSearchLocationMenuModelRole

    case enumRole:
    of MessageSearchLocationMenuModelRole.Value: 
      result = newQVariant(item.getValue)
    of MessageSearchLocationMenuModelRole.Title: 
      result = newQVariant(item.getTitle)
    of MessageSearchLocationMenuModelRole.ImageSource: 
      result = newQVariant(item.getImageSource)
    of MessageSearchLocationMenuModelRole.IconName: 
      result = newQVariant(item.getIconName)
    of MessageSearchLocationMenuModelRole.IconColor: 
      result = newQVariant(item.getIconColor)
    of MessageSearchLocationMenuModelRole.IsIdenticon: 
      result = newQVariant(item.getIsIdenticon)
    of MessageSearchLocationMenuModelRole.SubItems: 
      result = newQVariant(item.getSubItems)

  proc prepareLocationMenu*(self: MessageSearchLocationMenuModel, status: Status,
    chats: seq[Chat], communities: seq[Community]) =

    self.beginResetModel()

    self.items = @[]
    var item = initMessageSearchLocationMenuItem(status,
      SEARCH_MENU_LOCATION_CHAT_SECTION_NAME, 
      SEARCH_MENU_LOCATION_CHAT_SECTION_NAME, "", "chat", "", false)
    item.prepareSubItems(chats, false)
    self.items.add(item)

    for co in communities:
      item = initMessageSearchLocationMenuItem(status, co.id, co.name, 
        co.communityImage.thumbnail, "", co.communityColor, 
        co.communityImage.thumbnail.len == 0)
      item.prepareSubItems(co.chats, true)
      self.items.add(item)

    self.endResetModel()

  proc getLocationItemForCommunityId*(self: MessageSearchLocationMenuModel, 
    communityId: string, found: var bool): MessageSearchLocationMenuItem =

    found = false
    for i in self.items:
      if (i.getValue() == communityId):
        found = true
        return i

  proc getLocationSubItemForChatId*(self: MessageSearchLocationMenuModel, 
    chatId: string, found: var bool): MessageSearchLocationMenuSubItem =

    for i in self.items:
      let subItem = i.getLocationSubItemForChatId(chatId, found)
      if (found):
        return subItem
