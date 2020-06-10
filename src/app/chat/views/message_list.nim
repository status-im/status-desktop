import NimQml, Tables
import ../../../status/chat
import ../../../signals/types

type
  ChatMessageRoles {.pure.} = enum
    UserName = UserRole + 1,
    Message = UserRole + 2,
    Timestamp = UserRole + 3
    Identicon = UserRole + 4
    IsCurrentUser = UserRole + 5
    ContentType = UserRole + 6
    Sticker = UserRole + 7
    FromAuthor = UserRole + 8
    Clock = UserRole + 9
    ChatId = UserRole + 10
    SectionIdentifier = UserRole + 11

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

  proc chatIdentifier(self: ChatMessageList, chatId:string): ChatMessage =
    result = newChatMessage();
    result.contentType = ContentType.ChatIdentifier;
    result.chatId = chatId


  proc newChatMessageList*(chatId: string): ChatMessageList =
    new(result, delete)
    result.messages = @[result.chatIdentifier(chatId)]
    result.setup

  method rowCount(self: ChatMessageList, index: QModelIndex = nil): int =
    return self.messages.len

  proc sectionIdentifier(message: ChatMessage): string =
    result = message.fromAuthor
    # Force section change, because group status messages are sent with the
    # same fromAuthor, and ends up causing the header to not be shown
    if message.contentType == ContentType.Group:
      result = "GroupChatMessage"

  method data(self: ChatMessageList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.messages.len:
      return
    let message = self.messages[index.row]
    let chatMessageRole = role.ChatMessageRoles
    case chatMessageRole:
      of ChatMessageRoles.UserName: result = newQVariant(message.userName)
      of ChatMessageRoles.Message: result = newQVariant(message.message)
      of ChatMessageRoles.Timestamp: result = newQVariant(message.timestamp)
      of ChatMessageRoles.Clock: result = newQVariant($message.clock)
      of ChatMessageRoles.Identicon: result = newQVariant(message.identicon)
      of ChatMessageRoles.IsCurrentUser: result = newQVariant(message.isCurrentUser)
      of ChatMessageRoles.ContentType: result = newQVariant(message.contentType.int)
      of ChatMessageRoles.Sticker: result = newQVariant(message.sticker)
      of ChatMessageRoles.FromAuthor: result = newQVariant(message.fromAuthor)
      of ChatMessageRoles.ChatId: result = newQVariant(message.chatId)
      of ChatMessageRoles.SectionIdentifier: result = newQVariant(sectionIdentifier(message))


  method roleNames(self: ChatMessageList): Table[int, string] =
    {
      ChatMessageRoles.UserName.int:"userName",
      ChatMessageRoles.Message.int:"message",
      ChatMessageRoles.Timestamp.int:"timestamp",
      ChatMessageRoles.Clock.int:"clock",
      ChatMessageRoles.Identicon.int:"identicon",
      ChatMessageRoles.IsCurrentUser.int:"isCurrentUser",
      ChatMessageRoles.ContentType.int:"contentType",
      ChatMessageRoles.Sticker.int:"sticker",
      ChatMessageRoles.FromAuthor.int:"fromAuthor",
      ChatMessageRoles.ChatId.int:"chatId",
      ChatMessageRoles.SectionIdentifier.int: "sectionIdentifier"
    }.toTable

  proc add*(self: ChatMessageList, message: ChatMessage) =
    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len)
    self.messages.add(message)
    self.endInsertRows()

  proc add*(self: ChatMessageList, messages: seq[ChatMessage]) =
    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len)
    for message in messages:
      self.messages.add(message)
    self.endInsertRows()

