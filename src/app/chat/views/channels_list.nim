import NimQml
import Tables

import ../../../models/chat

type
  ChannelsRoles {.pure.} = enum
    Name = UserRole + 1,
    LastMessage = UserRole + 2
    Timestamp = UserRole + 3
    UnreadMessages = UserRole + 4

QtObject:
  type
    ChannelsList* = ref object of QAbstractListModel
      model*: ChatModel
      chats*: seq[ChatItem]

  proc setup(self: ChannelsList) = self.QAbstractListModel.setup

  proc delete(self: ChannelsList) = self.QAbstractListModel.delete

  proc newChannelsList*(model: ChatModel): ChannelsList =
    new(result, delete)
    result.model = model
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

  method roleNames(self: ChannelsList): Table[int, string] =
    { 
      ChannelsRoles.Name.int:"name",
      ChannelsRoles.Timestamp.int:"timestamp",
      ChannelsRoles.LastMessage.int: "lastMessage",
      ChannelsRoles.UnreadMessages.int: "unviewedMessagesCount"
    }.toTable

  proc addChatItemToList*(self: ChannelsList, channel: ChatItem): int =
    self.beginInsertRows(newQModelIndex(), self.chats.len, self.chats.len)
    self.chats.add(channel)
    self.endInsertRows()
    
    result = self.chats.len - 1

  proc getChannel*(self: ChannelsList, index: int): ChatItem =
    self.chats[index]

  proc upsertChannel(self: ChannelsList, channel: ChatItem): int =
    let idx = self.chats.findById(channel.id)
    if idx == -1:
      result = self.addChatItemToList(channel)
    else:
      result = idx

  proc updateChat*(self: ChannelsList, channel: ChatItem) =
    let idx = self.upsertChannel(channel)
    self.chats[idx] = channel
    let topLeft = self.createIndex(idx, 0, nil)
    let bottomRight = self.createIndex(idx, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[ChannelsRoles.Timestamp.int, ChannelsRoles.LastMessage.int, ChannelsRoles.UnreadMessages.int])
