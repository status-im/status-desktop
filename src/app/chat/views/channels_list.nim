import NimQml, Tables
import ../../../status/chat/[chat, message]

type
  ChannelsRoles {.pure.} = enum
    Name = UserRole + 1,
    LastMessage = UserRole + 2
    Timestamp = UserRole + 3
    UnreadMessages = UserRole + 4
    Identicon = UserRole + 5
    ChatType = UserRole + 6
    Color = UserRole + 7

QtObject:
  type
    ChannelsList* = ref object of QAbstractListModel
      chats*: seq[Chat]

  proc setup(self: ChannelsList) = self.QAbstractListModel.setup

  proc delete(self: ChannelsList) = self.QAbstractListModel.delete

  proc newChannelsList*(): ChannelsList =
    new(result, delete)
    result.chats = @[]
    result.setup()

  method rowCount(self: ChannelsList, index: QModelIndex = nil): int = self.chats.len

  method data(self: ChannelsList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.chats.len:
      return

    let chatItem = self.chats[index.row]
    let chatItemRole = role.ChannelsRoles
    case chatItemRole:
      of ChannelsRoles.Name: result = newQVariant(chatItem.name)
      of ChannelsRoles.Timestamp: result = newQVariant($chatItem.timestamp)
      of ChannelsRoles.LastMessage: result = newQVariant(chatItem.lastMessage.text)
      of ChannelsRoles.UnreadMessages: result = newQVariant(chatItem.unviewedMessagesCount)
      of ChannelsRoles.Identicon: result = newQVariant(chatItem.identicon)
      of ChannelsRoles.ChatType: result = newQVariant(chatItem.chatType.int)
      of ChannelsRoles.Color: result = newQVariant(chatItem.color)

  method roleNames(self: ChannelsList): Table[int, string] =
    {
      ChannelsRoles.Name.int:"name",
      ChannelsRoles.Timestamp.int:"timestamp",
      ChannelsRoles.LastMessage.int: "lastMessage",
      ChannelsRoles.UnreadMessages.int: "unviewedMessagesCount",
      ChannelsRoles.Identicon.int: "identicon",
      ChannelsRoles.ChatType.int: "chatType",
      ChannelsRoles.Color.int: "color"
    }.toTable

  proc addChatItemToList*(self: ChannelsList, channel: Chat): int =
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.chats.insert(channel, 0)
    self.endInsertRows()
    result = 0

  proc removeChatItemFromList*(self: ChannelsList, channel: string): int =
    let idx = self.chats.findIndexById(channel)
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.chats.delete(idx)
    self.endRemoveRows()

    result = self.chats.len

  proc getChannel*(self: ChannelsList, index: int): Chat = self.chats[index]

  proc upsertChannel(self: ChannelsList, channel: Chat): int =
    let idx = self.chats.findIndexById(channel.id)
    if not channel.active: return -1

    if idx == -1:
      result = self.addChatItemToList(channel)
    else:
      result = idx

  proc getChannelColor*(self: ChannelsList, name: string): string =
    for chat in self.chats:
      if chat.name == name:
        return chat.color

  proc updateChat*(self: ChannelsList, channel: Chat) =
    let idx = self.upsertChannel(channel)
    if idx == -1: return
    
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.chats.len, 0, nil)
    if idx != 0: # Move last updated chat to the top of the list
      self.chats.delete(idx)
      self.chats.insert(channel, 0)
    else:
      self.chats[0] = channel

    self.dataChanged(topLeft, bottomRight, @[ChannelsRoles.Name.int, ChannelsRoles.LastMessage.int, ChannelsRoles.Timestamp.int, ChannelsRoles.UnreadMessages.int, ChannelsRoles.Identicon.int, ChannelsRoles.ChatType.int, ChannelsRoles.Color.int])

  proc clearUnreadMessagesCount*(self: ChannelsList, channel: var Chat) =
    let idx = self.chats.findIndexById(channel.id)
    if idx == -1: return

    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.chats.len, 0, nil)
    channel.unviewedMessagesCount = 0
    self.chats[idx] = channel

    self.dataChanged(topLeft, bottomRight, @[ChannelsRoles.Name.int, ChannelsRoles.LastMessage.int, ChannelsRoles.Timestamp.int, ChannelsRoles.UnreadMessages.int, ChannelsRoles.Identicon.int, ChannelsRoles.ChatType.int, ChannelsRoles.Color.int])
