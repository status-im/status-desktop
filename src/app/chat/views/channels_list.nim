import NimQml, Tables
import random
import ../../../status/chat

const channelColors* = ["#fa6565", "#7cda00", "#887af9", "#51d0f0", "#FE8F59", "#d37ef4"]

type
  ChannelsRoles {.pure.} = enum
    Name = UserRole + 1,
    LastMessage = UserRole + 2
    Timestamp = UserRole + 3
    UnreadMessages = UserRole + 4
    Identicon = UserRole + 5
    ChatType = UserRole + 6

QtObject:
  type
    ChannelsList* = ref object of QAbstractListModel
      chats*: seq[ChatItem]

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
      of ChannelsRoles.LastMessage: result = newQVariant(chatItem.lastMessage)
      of ChannelsRoles.UnreadMessages: result = newQVariant(chatItem.unviewedMessagesCount)
      of ChannelsRoles.Identicon: result = newQVariant(chatItem.identicon)
      of ChannelsRoles.ChatType: result = newQVariant(chatItem.chatType.int)

  method roleNames(self: ChannelsList): Table[int, string] =
    {
      ChannelsRoles.Name.int:"name",
      ChannelsRoles.Timestamp.int:"timestamp",
      ChannelsRoles.LastMessage.int: "lastMessage",
      ChannelsRoles.UnreadMessages.int: "unviewedMessagesCount",
      ChannelsRoles.Identicon.int: "identicon",
      ChannelsRoles.ChatType.int: "chatType"
    }.toTable

  proc addChatItemToList*(self: ChannelsList, channel: ChatItem): int =
    if channel.color == "":
      randomize()
      channel.color = channelColors[rand(channelColors.len - 1)]
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.chats.insert(channel, 0)
    self.endInsertRows()
    result = self.chats.len - 1

  proc removeChatItemFromList*(self: ChannelsList, channel: string): int =
    let idx = self.chats.findById(channel)
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.chats.delete(idx)
    self.endRemoveRows()

    result = self.chats.len

  proc getChannel*(self: ChannelsList, index: int): ChatItem = self.chats[index]

  proc upsertChannel(self: ChannelsList, channel: ChatItem): int =
    let idx = self.chats.findById(channel.id)
    if idx == -1:
      result = self.addChatItemToList(channel)
    else:
      result = idx

  proc getChannelColor*(self: ChannelsList, name: string): string =
    for chat in self.chats:
      if chat.name == name:
        return chat.color
    return channelColors[0]

  proc updateChat*(self: ChannelsList, channel: ChatItem) =
    let idx = self.upsertChannel(channel)
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.chats.len - 1, 0, nil)
    if(idx != 0): # Move last updated chat to the top of the list
      self.chats.del(idx)
      self.chats.insert(channel, 0)
    else:
      self.chats[0] = channel

    self.dataChanged(topLeft, bottomRight, @[ChannelsRoles.Name.int, ChannelsRoles.LastMessage.int, ChannelsRoles.Timestamp.int, ChannelsRoles.LastMessage.int, ChannelsRoles.UnreadMessages.int, ChannelsRoles.Identicon.int, ChannelsRoles.LastMessage.int])
