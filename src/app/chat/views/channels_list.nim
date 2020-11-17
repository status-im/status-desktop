import NimQml, Tables
import ../../../status/chat/[chat, message]
import ../../../status/status
import ../../../status/ens
import ../../../status/accounts
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
    HasMentions = UserRole + 8
    ContentType = UserRole + 9
    Muted = UserRole + 10
    Id = UserRole + 11

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

  proc userNameOrAlias(self: ChannelsList, pubKey: string): string =
    if self.status.chat.contacts.hasKey(pubKey):
      return ens.userNameOrAlias(self.status.chat.contacts[pubKey])
    generateAlias(pubKey)

  proc chatName(self: ChannelsList, chatItem: Chat): string =
    if not chatItem.chatType.isOneToOne: return chatItem.name
    if chatItem.ensName != "":
      return "@" & userName(chatItem.ensName).userName(true)      
    return self.userNameOrAlias(chatItem.id)

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
      of ChannelsRoles.Name: result = newQVariant(self.chatName(chatItem))
      of ChannelsRoles.Timestamp: result = newQVariant($chatItem.timestamp)
      of ChannelsRoles.LastMessage: result = newQVariant(self.renderBlock(chatItem.lastMessage))
      of ChannelsRoles.ContentType: result = newQVariant(chatItem.lastMessage.contentType.int)
      of ChannelsRoles.UnreadMessages: result = newQVariant(chatItem.unviewedMessagesCount)
      of ChannelsRoles.Identicon: result = newQVariant(chatItem.identicon)
      of ChannelsRoles.ChatType: result = newQVariant(chatItem.chatType.int)
      of ChannelsRoles.Color: result = newQVariant(chatItem.color)
      of ChannelsRoles.HasMentions: result = newQVariant(chatItem.hasMentions)
      of ChannelsRoles.Muted: result = newQVariant(chatItem.muted.bool)
      of ChannelsRoles.Id: result = newQVariant($chatItem.id)

  method roleNames(self: ChannelsList): Table[int, string] =
    {
      ChannelsRoles.Name.int:"name",
      ChannelsRoles.Timestamp.int:"timestamp",
      ChannelsRoles.LastMessage.int: "lastMessage",
      ChannelsRoles.UnreadMessages.int: "unviewedMessagesCount",
      ChannelsRoles.Identicon.int: "identicon",
      ChannelsRoles.ChatType.int: "chatType",
      ChannelsRoles.Color.int: "color",
      ChannelsRoles.HasMentions.int: "hasMentions",
      ChannelsRoles.ContentType.int: "contentType",
      ChannelsRoles.Muted.int: "muted",
      ChannelsRoles.Id.int: "id"
    }.toTable

  proc addChatItemToList*(self: ChannelsList, channel: Chat): int =
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

  proc getChannel*(self: ChannelsList, index: int): Chat = self.chats[index]

  proc getChannelById*(self: ChannelsList, chatId: string): Chat =
    for chat in self.chats:
      if chat.id == chatId:
        return chat
  
  proc getChannelByName*(self: ChannelsList, name: string): Chat =
    for chat in self.chats:
      if chat.name == name:
        return chat

  proc upsertChannel(self: ChannelsList, channel: Chat): int =
    let idx = self.chats.findIndexById(channel.id)
    if idx == -1:
        if channel.isActive:
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

  proc updateChat*(self: ChannelsList, channel: Chat, moveToTop: bool = true) =
    let idx = self.upsertChannel(channel)
    if idx == -1: return
    
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.chats.len, 0, nil)

    if moveToTop:
      if idx != 0: # Move last updated chat to the top of the list
        self.chats.delete(idx)
        self.chats.insert(channel, 0)
      else:
        self.chats[0] = channel

    self.dataChanged(topLeft, bottomRight, @[ChannelsRoles.Name.int, ChannelsRoles.ContentType.int, ChannelsRoles.LastMessage.int, ChannelsRoles.Timestamp.int, ChannelsRoles.UnreadMessages.int, ChannelsRoles.Identicon.int, ChannelsRoles.ChatType.int, ChannelsRoles.Color.int, ChannelsRoles.HasMentions.int, ChannelsRoles.Muted.int])

  proc clearUnreadMessagesCount*(self: ChannelsList, channel: var Chat) =
    let idx = self.chats.findIndexById(channel.id)
    if idx == -1: return

    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.chats.len, 0, nil)
    channel.unviewedMessagesCount = 0
    channel.hasMentions = false
    self.chats[idx] = channel

    self.dataChanged(topLeft, bottomRight, @[ChannelsRoles.Name.int, ChannelsRoles.ContentType.int, ChannelsRoles.LastMessage.int, ChannelsRoles.Timestamp.int, ChannelsRoles.UnreadMessages.int, ChannelsRoles.Identicon.int, ChannelsRoles.ChatType.int, ChannelsRoles.Color.int, ChannelsRoles.HasMentions.int, ChannelsRoles.Muted.int])

  proc renderInline(self: ChannelsList, elem: TextItem): string =
    case elem.textType:
    of "mention": result = self.userNameOrAlias(elem.literal)
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

