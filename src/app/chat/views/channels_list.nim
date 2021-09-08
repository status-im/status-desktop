import NimQml, Tables
import algorithm
import status/chat/[chat]
import status/status
import status/accounts
import status/types/[message]
import strutils

type
  ChannelsRoles {.pure.} = enum
    Name = UserRole + 1,
    LastMessage = UserRole + 2
    Timestamp = UserRole + 3
    UnreadMessages = UserRole + 4
    Identicon = UserRole + 5
    ChatType = UserRole + 6
    Color = UserRole + 7
    MentionsCount = UserRole + 8
    ContentType = UserRole + 9
    Muted = UserRole + 10
    Id = UserRole + 11
    Description = UserRole + 12
    CategoryId = UserRole + 13
    Position = UserRole + 14

QtObject:
  type
    ChannelsList* = ref object of QAbstractListModel
      chats*: seq[Chat]
      status: Status

  proc setup(self: ChannelsList) = self.QAbstractListModel.setup

  proc delete(self: ChannelsList) = 
    self.chats = @[]
    self.QAbstractListModel.delete

  proc newChannelsList*(status: Status): ChannelsList =
    new(result, delete)
    result.chats = @[]
    result.status = status
    result.setup()

  method rowCount*(self: ChannelsList, index: QModelIndex = nil): int = self.chats.len

  proc renderBlock(self: ChannelsList, message: Message): string

  method data(self: ChannelsList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.chats.len:
      return

    let chatItem = self.chats[index.row]

    let chatItemRole = role.ChannelsRoles
    case chatItemRole:
      of ChannelsRoles.Name: result = newQVariant(self.status.chat.chatName(chatItem))
      of ChannelsRoles.Timestamp: result = newQVariant($chatItem.timestamp)
      of ChannelsRoles.LastMessage: result = newQVariant(self.renderBlock(chatItem.lastMessage))
      of ChannelsRoles.ContentType: result = newQVariant(chatItem.lastMessage.contentType.int)
      of ChannelsRoles.UnreadMessages: result = newQVariant(chatItem.unviewedMessagesCount)
      of ChannelsRoles.Identicon: result = newQVariant(chatItem.identicon)
      of ChannelsRoles.ChatType: result = newQVariant(chatItem.chatType.int)
      of ChannelsRoles.Color: result = newQVariant(chatItem.color)
      of ChannelsRoles.MentionsCount: result = newQVariant(chatItem.mentionsCount.int)
      of ChannelsRoles.Muted: result = newQVariant(chatItem.muted.bool)
      of ChannelsRoles.Id: result = newQVariant($chatItem.id)
      of ChannelsRoles.CategoryId: result = newQVariant(chatItem.categoryId)
      of ChannelsRoles.Description: result = newQVariant(chatItem.description)
      of ChannelsRoles.Position: result = newQVariant(chatItem.position)

  method roleNames(self: ChannelsList): Table[int, string] =
    {
      ChannelsRoles.Name.int:"name",
      ChannelsRoles.Timestamp.int:"timestamp",
      ChannelsRoles.LastMessage.int: "lastMessage",
      ChannelsRoles.UnreadMessages.int: "unviewedMessagesCount",
      ChannelsRoles.Identicon.int: "identicon",
      ChannelsRoles.ChatType.int: "chatType",
      ChannelsRoles.Color.int: "color",
      ChannelsRoles.MentionsCount.int: "mentionsCount",
      ChannelsRoles.ContentType.int: "contentType",
      ChannelsRoles.Muted.int: "muted",
      ChannelsRoles.Id.int: "id",
      ChannelsRoles.Description.int: "description",
      ChannelsRoles.CategoryId.int: "categoryId",
      ChannelsRoles.Position.int: "position"
    }.toTable

  proc sortChats(x, y: Chat): int =
    if x.position < y.position: -1
    elif x.position == y.position: 0
    else: 1

  proc setChats*(self: ChannelsList, chats: seq[Chat]) =
    self.beginResetModel()
    var copy = chats
    copy.sort(sortChats)
    self.chats = copy
    self.endResetModel()

  proc addChatItemToList*(self: ChannelsList, channel: Chat): int =
    var found = false
    for chat in self.chats:
      if chat.id == channel.id:
        found = true
        break
    
    if not found:
      self.beginInsertRows(newQModelIndex(), 0, 0)
      self.chats.insert(channel, 0)
      self.endInsertRows()
    
    result = 0

  proc removeChatItemFromList*(self: ChannelsList, channel: string): int =
    let idx = self.chats.findIndexById(channel)
    if idx == -1: return
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.chats.delete(idx)
    self.endRemoveRows()

    result = self.chats.len

  proc getChannel*(self: ChannelsList, index: int): Chat = 
    if index < 0 or index >= self.chats.len:
      return

    result = self.chats[index]

  proc getChannelById*(self: ChannelsList, chatId: string): Chat =
    for chat in self.chats:
      if chat.id == chatId:
        return chat
  
  proc getChannelById*(self: ChannelsList, chatId: string, found: var bool): Chat =
    found = false
    for chat in self.chats:
      if chat.id == chatId:
        found = true
        return chat
  
  proc getChannelByName*(self: ChannelsList, name: string): Chat =
    for chat in self.chats:
      if chat.name == name:
        return chat

  proc upsertChannel(self: ChannelsList, channel: Chat): int =
    let idx = self.chats.findIndexById(channel.id)
    if idx == -1:
        if channel.isActive and channel.chatType != ChatType.Profile and channel.chatType != ChatType.Timeline:
          # We only want to add a channel to the list if it is active
          # otherwise, we'll end up with zombie channels on the list
          result = self.addChatItemToList(channel)
        else:
          result = -1
    else:
      result = idx

  proc getChannelColor*(self: ChannelsList, name: string): string =
    let channel = self.getChannelByName(name)
    if (channel == nil): return
    return channel.color

  proc getChannelType*(self: ChannelsList, id: string): int {.slot.} =
    let channel = self.getChannelById(id)
    if (channel == nil): return ChatType.Unknown.int
    return channel.chatType.int

  proc updateChat*(self: ChannelsList, channel: Chat) =
    let idx = self.upsertChannel(channel)
    if idx == -1: return
    
    let topLeft = self.createIndex(idx, 0, nil)
    let bottomRight = self.createIndex(idx, 0, nil)

    self.chats[idx] = channel

    self.dataChanged(topLeft, bottomRight,
     @[ChannelsRoles.Name.int,
      ChannelsRoles.Description.int,
      ChannelsRoles.ContentType.int,
      ChannelsRoles.LastMessage.int,
      ChannelsRoles.Timestamp.int, 
      ChannelsRoles.UnreadMessages.int, 
      ChannelsRoles.Identicon.int, 
      ChannelsRoles.ChatType.int, 
      ChannelsRoles.Color.int, 
      ChannelsRoles.MentionsCount.int, 
      ChannelsRoles.Muted.int,
      ChannelsRoles.Position.int])

  proc clearUnreadMessages*(self: ChannelsList, channelId: string) =
    let idx = self.chats.findIndexById(channelId)
    if idx == -1: 
      return

    let index = self.createIndex(idx, 0, nil)
    self.chats[idx].unviewedMessagesCount = 0
    self.chats[idx].unviewedMentionsCount = 0

    self.dataChanged(index, index, @[ChannelsRoles.UnreadMessages.int])

  proc clearAllMentionsFromChannelWithId*(self: ChannelsList, channelId: string) =
    let idx = self.chats.findIndexById(channelId)
    if idx == -1: 
      return

    let index = self.createIndex(idx, 0, nil)
    self.chats[idx].mentionsCount = 0
    self.chats[idx].unviewedMentionsCount = 0

    self.dataChanged(index, index, @[ChannelsRoles.MentionsCount.int])

  proc clearAllMentionsFromAllChannels*(self: ChannelsList) =
    for c in self.chats:
      self.clearAllMentionsFromChannelWithId(c.id)

  proc decrementMentions*(self: ChannelsList, channelId: string) =
    let idx = self.chats.findIndexById(channelId)
    if idx == -1: 
      return

    let index = self.createIndex(idx, 0, nil)
    self.chats[idx].mentionsCount.dec
    self.chats[idx].unviewedMentionsCount.dec

    self.dataChanged(index, index, @[ChannelsRoles.MentionsCount.int])

  proc renderInline(self: ChannelsList, elem: TextItem): string =
    case elem.textType:
    of "mention": result = self.status.chat.userNameOrAlias(elem.literal)
    of "link": result = elem.destination
    else: result = escape_html(elem.literal)

  proc renderBlock(self: ChannelsList, message: Message): string =
    for pMsg in message.parsedText:
      case pMsg.textType:
        of "paragraph":
          for children in pMsg.children:
            result = result & self.renderInline(children)
        else:
          result = escape_html(pMsg.literal)

