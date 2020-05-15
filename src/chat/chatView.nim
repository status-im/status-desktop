import NimQml
import Tables
# import core as chat

type
  RoleNames {.pure.} = enum
    Name = UserRole + 1,

QtObject:
  type
    ChatsModel* = ref object of QAbstractListModel
      names*: seq[string]
      callResult: string
      sendMessage: proc (msg: string):  string

  proc delete(self: ChatsModel) =
    self.QAbstractListModel.delete

  proc setup(self: ChatsModel) =
    self.QAbstractListModel.setup

  proc newChatsModel*(sendMessage: proc): ChatsModel =
    new(result, delete)
    result.sendMessage = sendMessage
    result.names = @[]
    result.setup

  proc addNameTolist*(self: ChatsModel, chatId: string) {.slot.} =
    # chat.join(chatId)
    self.beginInsertRows(newQModelIndex(), self.names.len, self.names.len)
    self.names.add(chatId)
    self.endInsertRows()

  method rowCount(self: ChatsModel, index: QModelIndex = nil): int =
    return self.names.len

  method data(self: ChatsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.names.len:
      return
    return newQVariant(self.names[index.row])

  method roleNames(self: ChatsModel): Table[int, string] =
    { RoleNames.Name.int:"name"}.toTable

  # Accesors
  proc callResult*(self: ChatsModel): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: ChatsModel, callResult: string) {.signal.}

  proc setCallResult(self: ChatsModel, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: ChatsModel, callResult: string) = self.setCallResult(callResult)

  # Binding between a QML variable and accesors is done here
  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: ChatsModel, inputJSON: string) {.slot.} =
    self.setCallResult(self.sendMessage(inputJSON))
    echo "Done!: ", self.callResult

  proc onMessage*(self: ChatsModel, message: string) {.slot.} =
    self.setCallResult(message)
    echo "Received message: ", message
