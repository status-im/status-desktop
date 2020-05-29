import NimQml
import Tables
import views/channels_list
import views/message_list
import ../../signals/types
import ../../models/chat
import random

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

  proc onSend*(self: ChatsView, inputJSON: string) {.slot.} =
    discard self.model.sendMessage(self.activeChannel, inputJSON)

  proc activeChannel*(self: ChatsView): string {.slot.} = self.activeChannel

  proc getChannelColor*(self: ChatsView, channel:string): string {.slot.} =
    var selectedChannel: ChatItem
    try:
      selectedChannel = self.chats.getChannelByName(channel)
    except:
      return channelColors[0]
    
    result = selectedChannel.color

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

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    let chatType = ChatType(chatTypeInt)
    
    if self.model.hasChannel(channel):
      result = self.chats.chats.findById(channel)
    else:
      self.model.join(channel)
      randomize()
      let randomColorIndex = rand(channelColors.len - 1)
      let chatItem = newChatItem(id = channel, chatType, color = channelColors[randomColorIndex])
      result = self.chats.addChatItemToList(chatItem)

    self.setActiveChannel(channel)

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.model.leave(self.activeChannel)
    let channelCount = self.chats.removeChatItemFromList(self.activeChannel)
    if channelCount == 0:
      self.setActiveChannel("")
    else:
      let nextChannel = self.chats.chats[self.chats.chats.len - 1]
      self.setActiveChannel(nextChannel.name)

  proc updateChat*(self: ChatsView, chat: ChatItem) =
    self.chats.updateChat(chat)
