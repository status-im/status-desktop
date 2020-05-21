import NimQml
import Tables
import messages
import messageList
import ../signals/types
# import core as chat

type
  RoleNames {.pure.} = enum
    Name = UserRole + 1,

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      names*: seq[string]
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel: string
      sendMessage: proc (view: ChatsView, channel: string, msg: string):  string

  proc delete(self: ChatsView) = self.QAbstractListModel.delete

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc newChatsView*(sendMessage: proc): ChatsView =
    new(result, delete)
    result.sendMessage = sendMessage
    result.names = @[]
    result.activeChannel = ""
    result.messageList = initTable[string, ChatMessageList]() # newChatMessageList()
    result.setup

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList()

  proc addNameTolist*(self: ChatsView, channel: string) {.slot.} =
    if(self.activeChannel == ""):
      self.activeChannel = channel

    self.beginInsertRows(newQModelIndex(), self.names.len, self.names.len)
    self.names.add(channel)
    self.upsertChannel(channel)
    self.endInsertRows()

  method rowCount(self: ChatsView, index: QModelIndex = nil): int =
    return self.names.len

  method data(self: ChatsView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.names.len:
      return
    return newQVariant(self.names[index.row])

  method roleNames(self: ChatsView): Table[int, string] =
    { RoleNames.Name.int:"name"}.toTable

  # Accesors
  proc callResult*(self: ChatsView): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: ChatsView, callResult: string) {.signal.}

  proc setCallResult(self: ChatsView, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: ChatsView, callResult: string) = self.setCallResult(callResult)

  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: ChatsView, inputJSON: string) {.slot.} =
    self.setCallResult(self.sendMessage(self, self.activeChannel, inputJSON))

  proc pushMessage*(self:ChatsView, channel: string, message: ChatMessage) =
    self.upsertChannel(channel)
    self.messageList[channel].add(message)

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex(self: ChatsView, index: int) {.slot.} =
    if self.activeChannel == self.names[index]: return
    self.activeChannel = self.names[index]
    self.activeChannelChanged()

  QtProperty[string] activeChannel:
    write = setActiveChannel
    notify = activeChannelChanged

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.messageList[self.activeChannel])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged