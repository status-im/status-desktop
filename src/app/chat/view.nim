import NimQml
import Tables
import json
import chronicles

import ../../signals/types
import ../../status/chat
import ../../status/status

import views/channels_list
import views/message_list
import views/chat_item

logScope:
  topics = "chats-view"

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      status: Status
      chats*: ChannelsList
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel*: ChatItemView

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = self.QAbstractListModel.delete

  proc newChatsView*(status: Status): ChatsView =
    new(result, delete)
    result.status = status
    result.chats = newChannelsList()
    result.activeChannel = newChatItemView()
    result.messageList = initTable[string, ChatMessageList]()
    result.setup()

  proc getChatsList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChatsList

  proc getChannelColor*(self: ChatsView, channel: string): string {.slot.} =
    self.chats.getChannelColor(channel)

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if(self.chats.chats.len == 0): return
    var response = self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
    if not response.hasKey("error"):
      self.chats.clearUnreadMessagesCount(self.activeChannel.chatItem)
    let selectedChannel = self.chats.getChannel(index)
    if self.activeChannel.id == selectedChannel.id: return
    self.activeChannel.setChatItem(selectedChannel)
    self.status.chat.setActiveChannel(selectedChannel.id)
    self.activeChannelChanged()

  proc getActiveChannelIdx(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats.chats.findIndexById(self.activeChannel.id))

  QtProperty[QVariant] activeChannelIndex:
    read = getActiveChannelIdx
    write = setActiveChannelByIndex
    notify = activeChannelChanged

  proc setActiveChannel*(self: ChatsView, channel: string) =
    if(channel == ""): return
    self.activeChannel.setChatItem(self.chats.getChannel(self.chats.chats.findIndexById(channel)))
    self.activeChannelChanged()

  proc getActiveChannel*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.activeChannel)

  QtProperty[QVariant] activeChannel:
    read = getActiveChannel
    write = setActiveChannel
    notify = activeChannelChanged

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList(channel)
  
  proc messagePushed*(self: ChatsView) {.signal.}

  proc pushMessage*(self:ChatsView, message: ChatMessage) =
    self.upsertChannel(message.chatId)
    self.messageList[message.chatId].add(message)
    self.messagePushed()

  proc pushMessages*(self:ChatsView, messages: seq[Message]) =
    for msg in messages:
      self.upsertChannel(msg.chatId)
      self.messageList[msg.chatId].add(msg.toChatMessage())
      self.messagePushed()

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel.id)
    return newQVariant(self.messageList[self.activeChannel.id])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc pushChatItem*(self: ChatsView, chatItem: Chat) =
    discard self.chats.addChatItemToList(chatItem)
    self.messagePushed()

  proc sendMessage*(self: ChatsView, message: string) {.slot.} =
    discard self.status.chat.sendMessage(self.activeChannel.id, message)

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    self.status.chat.join(channel, ChatType(chatTypeInt))

  proc messagesLoaded*(self: ChatsView) {.signal.}

  proc loadMoreMessages*(self: ChatsView) {.slot.} =
    trace "Loading more messages", chaId = self.activeChannel.id
    self.status.chat.chatMessages(self.activeChannel.id, false)
    self.messagesLoaded();

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.status.chat.leave(self.activeChannel.id)

  proc updateChat*(self: ChatsView, chat: Chat) =
    self.chats.updateChat(chat)
