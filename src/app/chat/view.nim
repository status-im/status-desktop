import NimQml
import Tables
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
      messageList: ChatMessageList
      sendMessage: proc (msg: string):  string

  proc delete(self: ChatsView) =
    self.QAbstractListModel.delete

  proc setup(self: ChatsView) =
    self.QAbstractListModel.setup

  proc newChatsView*(sendMessage: proc): ChatsView =
    new(result, delete)
    result.sendMessage = sendMessage
    result.names = @[]
    result.messageList = newChatMessageList()
    result.setup

  proc addNameTolist*(self: ChatsView, chatId: string) {.slot.} =
    self.beginInsertRows(newQModelIndex(), self.names.len, self.names.len)
    self.names.add(chatId)
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

  # Binding between a QML variable and accesors is done here
  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: ChatsView, inputJSON: string) {.slot.} =
    self.setCallResult(self.sendMessage(inputJSON))
    echo "Done!: ", self.callResult

  proc onMessage*(self: ChatsView, message: string) {.slot.} =
    self.setCallResult(message)
    echo "Received message: ", message

  proc pushMessage*(self:ChatsView, message: Message) =
    self.messageList.add(message)

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.messageList)

  QtProperty[QVariant] messageList:
    read = getMessageList