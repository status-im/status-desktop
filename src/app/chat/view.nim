import NimQml
import Tables
import messages
import messageList
import ../../models/chat

type
  RoleNames {.pure.} = enum
    Name = UserRole + 1,

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      model: ChatModel
      names*: seq[string]
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel: string

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = self.QAbstractListModel.delete

  proc newChatsView*(model: ChatModel): ChatsView =
    new(result, delete)
    result.model = model
    result.names = @[]
    result.activeChannel = ""
    result.messageList = initTable[string, ChatMessageList]()
    result.setup()

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList()

  method rowCount(self: ChatsView, index: QModelIndex = nil): int = self.names.len

  method data(self: ChatsView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.names.len:
      return
    return newQVariant(self.names[index.row])

  method roleNames(self: ChatsView): Table[int, string] =
    { RoleNames.Name.int:"name"}.toTable

  proc onSend*(self: ChatsView, inputJSON: string) {.slot.} =
    discard self.model.sendMessage(self.activeChannel, inputJSON)

  proc pushMessage*(self:ChatsView, channel: string, message: ChatMessage) =
    self.upsertChannel(channel)
    self.messageList[channel].add(message)

  proc activeChannel*(self: ChatsView): string {.slot.} = self.activeChannel

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if self.activeChannel == self.names[index]: return
    self.activeChannel = self.names[index]
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

    self.beginInsertRows(newQModelIndex(), self.names.len, self.names.len)
    self.names.add(channel)
    self.upsertChannel(channel)
    self.endInsertRows()
    
    result = self.names.len - 1

  proc joinChat*(self: ChatsView, channel: string): int {.slot.} =
    self.setActiveChannel(channel)
    if self.model.hasChannel(channel):
      result = self.names.find(channel)
    else:
      self.model.join(channel)
      result = self.addToList(channel)
