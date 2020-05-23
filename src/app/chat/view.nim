import NimQml
import Tables
import views/channels_list
import views/message_list
import ../../models/chat

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      model: ChatModel
      chats: ChannelsList
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel: string

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = self.QAbstractListModel.delete

  proc newChatsView*(model: ChatModel): ChatsView =
    new(result, delete)
    result.model = model
    result.chats = newChannelsList(result.model)
    result.activeChannel = ""
    result.messageList = initTable[string, ChatMessageList]()
    result.setup()

  proc getChatsList(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChatsList

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList()

  proc onSend*(self: ChatsView, inputJSON: string) {.slot.} =
    discard self.model.sendMessage(self.activeChannel, inputJSON)

  proc pushMessage*(self:ChatsView, channel: string, message: ChatMessage) =
    self.upsertChannel(channel)
    self.messageList[channel].add(message)

  proc activeChannel*(self: ChatsView): string {.slot.} = self.activeChannel

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if self.activeChannel == self.chats.chats[index].name: return
    self.activeChannel = self.chats.chats[index].name
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

  proc addChatItemToList(self: ChatsView, channel: ChatItem): int =
    self.upsertChannel(channel.name)
    self.beginInsertRows(newQModelIndex(), self.chats.chats.len, self.chats.chats.len)
    self.chats.chats.add(channel)
    self.endInsertRows()
    
    result = self.chats.chats.len - 1

  proc joinChat*(self: ChatsView, channel: string): int {.slot.} =
    self.setActiveChannel(channel)
    self.chats.joinChat(channel)

  proc updateChat*(self: ChatsView, chat: ChatItem) =
    self.chats.updateChat(chat)
