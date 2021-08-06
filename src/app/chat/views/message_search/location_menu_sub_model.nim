import NimQml, Tables, strutils, strformat

import ../../../../status/chat/[chat]
import ../../../../status/[status]

import location_menu_sub_item

type
  MessageSearchLocationMenuSubModelRole {.pure.} = enum
    Value = UserRole + 1
    Text
    ImageSource
    IconName
    IconColor
    IsIdenticon

QtObject:
  type
    MessageSearchLocationMenuSubModel* = ref object of QAbstractListModel
      status: Status
      items: seq[MessageSearchLocationMenuSubItem]

  proc delete(self: MessageSearchLocationMenuSubModel) =
    self.QAbstractListModel.delete

  proc setup(self: MessageSearchLocationMenuSubModel) =
    self.QAbstractListModel.setup

  proc newMessageSearchLocationMenuSubModel*(status: Status): 
    MessageSearchLocationMenuSubModel =
    new(result, delete)
    result.status = status
    result.setup()

  proc `$`*(self: MessageSearchLocationMenuSubModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged*(self: MessageSearchLocationMenuSubModel) {.signal.}

  proc count*(self: MessageSearchLocationMenuSubModel): int {.slot.}  =
    self.items.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: MessageSearchLocationMenuSubModel, 
    index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: MessageSearchLocationMenuSubModel): 
    Table[int, string] =
    {
      MessageSearchLocationMenuSubModelRole.Value.int:"value",
      MessageSearchLocationMenuSubModelRole.Text.int:"text",
      MessageSearchLocationMenuSubModelRole.ImageSource.int:"imageSource",
      MessageSearchLocationMenuSubModelRole.IconName.int:"iconName",
      MessageSearchLocationMenuSubModelRole.IconColor.int:"iconColor",
      MessageSearchLocationMenuSubModelRole.IsIdenticon.int:"isIdenticon"
    }.toTable

  method data(self: MessageSearchLocationMenuSubModel, index: QModelIndex, 
    role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.MessageSearchLocationMenuSubModelRole

    case enumRole:
    of MessageSearchLocationMenuSubModelRole.Value: 
      result = newQVariant(item.getValue)
    of MessageSearchLocationMenuSubModelRole.Text: 
      result = newQVariant(item.getText)
    of MessageSearchLocationMenuSubModelRole.ImageSource: 
      result = newQVariant(item.getImageSource)
    of MessageSearchLocationMenuSubModelRole.IconName: 
      result = newQVariant(item.getIconName)
    of MessageSearchLocationMenuSubModelRole.IconColor: 
      result = newQVariant(item.getIconColor)
    of MessageSearchLocationMenuSubModelRole.IsIdenticon: 
      result = newQVariant(item.getIsIdenticon)

  proc prepareItems*(self: MessageSearchLocationMenuSubModel, chats: seq[Chat],
    isCommunityChannel: bool) =
    self.beginResetModel()

    self.items = @[]

    for c in chats:
      var text = self.status.chat.chatName(c)
      if (isCommunityChannel):
        self.items.add(initMessageSearchLocationMenuSubItem(c.id, text, "",
        "channel", c.color, false))
      else:
        if (text.endsWith(".stateofus.eth")):
          text = text[0 .. ^15]
      
        self.items.add(initMessageSearchLocationMenuSubItem(c.id, text, 
        c.identicon, "", c.color, c.identicon.len == 0))

    self.endResetModel()

  proc getLocationSubItemForChatId*(self: MessageSearchLocationMenuSubModel, 
    chatId: string, found: var bool): MessageSearchLocationMenuSubItem =

    found = false
    for i in self.items:
      if (i.getValue() == chatId):
        found = true
        return i