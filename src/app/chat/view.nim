import NimQml
import Tables
import views/channels_list
import views/message_list
import ../../signals/types
import ../../status/chat

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      model: ChatModel
      chats*: ChannelsList
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

  proc activeChannel*(self: ChatsView): string {.slot.} = self.activeChannel

  proc getChannelColor*(self: ChatsView, channel: string): string {.slot.} =
    self.chats.getChannelColor(channel)

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if(self.chats.chats.len == 0): return

    let selectedChannel = self.chats.getChannel(index)
    if self.activeChannel == selectedChannel.id: return
    self.activeChannel = selectedChannel.id
    self.activeChannelChanged()

  proc getActiveChannelIdx(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.chats.chats.findById(self.activeChannel))

  QtProperty[QVariant] activeChannelIndex:
    read = getActiveChannelIdx
    write = setActiveChannelByIndex
    notify = activeChannelChanged

  proc setActiveChannel*(self: ChatsView, channel: string) =
    self.activeChannel = channel
    self.activeChannelChanged()

  QtProperty[string] activeChannel:
    read = activeChannel
    write = setActiveChannel
    notify = activeChannelChanged

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList()

  proc pushMessage*(self:ChatsView, channel: string, message: ChatMessage) =
    self.upsertChannel(channel)
    self.messageList[channel].add(message)

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel)
    return newQVariant(self.messageList[self.activeChannel])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc pushChatItem*(self: ChatsView, chatItem: ChatItem) =
    discard self.chats.addChatItemToList(chatItem)

  proc sendMessage*(self: ChatsView, message: string) {.slot.} =
    discard self.model.sendMessage(self.activeChannel, message)

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    self.model.join(channel, ChatType(chatTypeInt))

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.model.leave(self.activeChannel)

  proc updateChat*(self: ChatsView, chat: ChatItem) =
    self.chats.updateChat(chat)
