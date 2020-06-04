import NimQml, Tables
import ../../../status/chat

type
  ChatMessageRoles {.pure.} = enum
    UserName = UserRole + 1,
    Message = UserRole + 2,
    Timestamp = UserRole + 3
    Identicon = UserRole + 4
    IsCurrentUser = UserRole + 5
    RepeatMessageInfo = UserRole + 6
    ContentType = UserRole + 7
    Sticker = UserRole + 8
    FromAuthor = UserRole + 9
    Clock = UserRole + 10
QtObject:
  type
    ChatMessageList* = ref object of QAbstractListModel
      messages*: seq[ChatMessage]

  proc delete(self: ChatMessageList) =
    self.QAbstractListModel.delete
    for message in self.messages:
      message.delete
    self.messages = @[]

  proc setup(self: ChatMessageList) =
    self.QAbstractListModel.setup

  proc newChatMessageList*(): ChatMessageList =
    new(result, delete)
    result.messages = @[]
    result.setup

  method rowCount(self: ChatMessageList, index: QModelIndex = nil): int =
    return self.messages.len

  method data(self: ChatMessageList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.messages.len:
      return
    let message = self.messages[index.row]
    let repeatMessageInfo = (index.row == 0) or message.fromAuthor != self.messages[index.row - 1].fromAuthor
    let chatMessageRole = role.ChatMessageRoles
    case chatMessageRole:
      of ChatMessageRoles.UserName: result = newQVariant(message.userName)
      of ChatMessageRoles.Message: result = newQVariant(message.message)
      of ChatMessageRoles.Timestamp: result = newQVariant(message.timestamp)
      of ChatMessageRoles.Clock: result = newQVariant($message.clock)
      of ChatMessageRoles.Identicon: result = newQVariant(message.identicon)
      of ChatMessageRoles.IsCurrentUser: result = newQVariant(message.isCurrentUser)
      of ChatMessageRoles.RepeatMessageInfo: result = newQVariant(repeatMessageInfo)
      of ChatMessageRoles.ContentType: result = newQVariant(message.contentType)
      of ChatMessageRoles.Sticker: result = newQVariant(message.sticker)
      of ChatMessageRoles.FromAuthor: result = newQVariant(message.fromAuthor)

  method roleNames(self: ChatMessageList): Table[int, string] =
    {
      ChatMessageRoles.UserName.int:"userName",
      ChatMessageRoles.Message.int:"message",
      ChatMessageRoles.Timestamp.int:"timestamp",
      ChatMessageRoles.Clock.int:"clock",
      ChatMessageRoles.Identicon.int:"identicon",
      ChatMessageRoles.IsCurrentUser.int:"isCurrentUser",
      ChatMessageRoles.RepeatMessageInfo.int:"repeatMessageInfo",
      ChatMessageRoles.ContentType.int:"contentType",
      ChatMessageRoles.Sticker.int:"sticker",
      ChatMessageRoles.FromAuthor.int:"fromAuthor"
    }.toTable

  proc add*(self: ChatMessageList, message: ChatMessage) =
    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len)
    self.messages.add(message)
    self.endInsertRows()
