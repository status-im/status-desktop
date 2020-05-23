import NimQml
import Tables
import messageList
import ../../models/chat

type
  RoleNames {.pure.} = enum
    Name = UserRole + 1,
    LastMessage = UserRole + 2
    Timestamp = UserRole + 3
    UnreadMessages = UserRole + 4

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      model: ChatModel
      chats: seq[ChatItem]
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel: string

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = self.QAbstractListModel.delete

  proc newChatsView*(model: ChatModel): ChatsView =
    new(result, delete)
    result.model = model
    result.chats = @[]
    result.activeChannel = ""
    result.messageList = initTable[string, ChatMessageList]()
    result.setup()

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList()

  method rowCount(self: ChatsView, index: QModelIndex = nil): int = self.chats.len

  method data(self: ChatsView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.chats.len:
      return

    let chatItem = self.chats[index.row]
    let chatItemRole = role.RoleNames
    case chatItemRole:
      of RoleNames.Name: result = newQVariant(chatItem.name)
      of RoleNames.Timestamp: result = newQVariant($chatItem.timestamp)
      of RoleNames.LastMessage: result = newQVariant(chatItem.lastMessage)
      of RoleNames.UnreadMessages: result = newQVariant(chatItem.unviewedMessagesCount)

  method roleNames(self: ChatsView): Table[int, string] =
    { 
      RoleNames.Name.int:"name",
      RoleNames.Timestamp.int:"timestamp",
      RoleNames.LastMessage.int: "lastMessage",
      RoleNames.UnreadMessages.int: "unviewedMessagesCount"
    }.toTable

  proc onSend*(self: ChatsView, inputJSON: string) {.slot.} =
    discard self.model.sendMessage(self.activeChannel, inputJSON)

  proc pushMessage*(self:ChatsView, channel: string, message: ChatMessage) =
    self.upsertChannel(channel)
    self.messageList[channel].add(message)

  proc activeChannel*(self: ChatsView): string {.slot.} = self.activeChannel

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if self.activeChannel == self.chats[index].name: return
    self.activeChannel = self.chats[index].name
    self.activeChannelChanged()

  QtProperty[string] activeChannel:
    read = activeChannel
    write = setActiveChannel
    notify = activeChannelChanged

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel)
    return newQVariant(self.messageList[self.activeChannel])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc setActiveChannel*(self: ChatsView, channel: string) =
    self.activeChannel = channel
    self.activeChannelChanged()

  proc addToList(self: ChatsView, channel: string): int =
    if(self.activeChannel == ""): self.setActiveChannel(channel)
    var chatItem = newChatItem()
    chatItem.name = channel
    self.upsertChannel(channel)
    self.beginInsertRows(newQModelIndex(), self.chats.len, self.chats.len)
    self.chats.add(chatItem)
    self.endInsertRows()
    
    result = self.chats.len - 1

  proc joinChat*(self: ChatsView, channel: string): int {.slot.} =
    self.setActiveChannel(channel)
    if self.model.hasChannel(channel):
      result = self.chats.findByName(channel)
    else:
      self.model.join(channel)
      result = self.addToList(channel)

  proc updateChat*(self: ChatsView, chat: ChatItem) =
    var idx = self.chats.findByName(chat.name)
    if idx > -1:
      self.chats[idx] = chat
      var x = self.createIndex(idx,0,nil)
      var y = self.createIndex(idx,0,nil)
      self.dataChanged(x, y, @[RoleNames.Timestamp.int, RoleNames.LastMessage.int, RoleNames.UnreadMessages.int])
