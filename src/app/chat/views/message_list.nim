import NimQml, Tables
import ../../../status/status
import ../../../status/accounts
import ../../../status/chat
import ../../../status/chat/[message,stickers]
import ../../../status/profile/profile
import ../../../status/ens
import strformat, strutils

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
    Id = UserRole + 12
    OutgoingStatus = UserRole + 13
    ResponseTo = UserRole + 14

QtObject:
  type
    ChatMessageList* = ref object of QAbstractListModel
      messages*: seq[Message]
      status: Status
      messageIndex: Table[string, int]

  proc delete(self: ChatMessageList) =
    self.messages = @[]
    self.messageIndex = initTable[string, int]()
    self.QAbstractListModel.delete

  proc setup(self: ChatMessageList) =
    self.QAbstractListModel.setup

  include message_format

  proc chatIdentifier(self: ChatMessageList, chatId:string): Message =
    result = Message()
    result.contentType = ContentType.ChatIdentifier;
    result.chatId = chatId

  proc newChatMessageList*(chatId: string, status: Status): ChatMessageList =
    new(result, delete)
    result.messages = @[result.chatIdentifier(chatId)]
    result.messageIndex = initTable[string, int]()
    result.status = status
    result.setup

  method rowCount(self: ChatMessageList, index: QModelIndex = nil): int =
    return self.messages.len

  method data(self: ChatMessageList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.messages.len:
      return
    let message = self.messages[index.row]
    let chatMessageRole = role.ChatMessageRoles
    case chatMessageRole:
      of ChatMessageRoles.UserName: result = newQVariant(message.alias)
      of ChatMessageRoles.Message: result = newQVariant(self.renderBlock(message))
      of ChatMessageRoles.Timestamp: result = newQVariant(message.timestamp)
      of ChatMessageRoles.Clock: result = newQVariant($message.clock)
      of ChatMessageRoles.Identicon: result = newQVariant(message.identicon)
      of ChatMessageRoles.IsCurrentUser: result = newQVariant(message.isCurrentUser)
      of ChatMessageRoles.ContentType: result = newQVariant(message.contentType.int)
      of ChatMessageRoles.Sticker: result = newQVariant(message.stickerHash.decodeContentHash())
      of ChatMessageRoles.FromAuthor: result = newQVariant(message.fromAuthor)
      of ChatMessageRoles.ChatId: result = newQVariant(message.chatId)
      of ChatMessageRoles.SectionIdentifier: result = newQVariant(sectionIdentifier(message))
      of ChatMessageRoles.Id: result = newQVariant(message.id)
      of ChatMessageRoles.OutgoingStatus: result = newQVariant(message.outgoingStatus)
      of ChatMessageRoles.ResponseTo: result = newQVariant(message.responseTo)

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
      ChatMessageRoles.SectionIdentifier.int: "sectionIdentifier",
      ChatMessageRoles.Id.int: "messageId",
      ChatMessageRoles.OutgoingStatus.int: "outgoingStatus",
      ChatMessageRoles.ResponseTo.int: "responseTo"
    }.toTable

  proc getMessageIndex(self: ChatMessageList, messageId: string): int {.slot.} =
    if not self.messageIndex.hasKey(messageId): return -1
    result = self.messageIndex[messageId]

  proc getReplyData(self: ChatMessageList, index: int, data: string): string {.slot.} =
    let message = self.messages[index]
    case data:
    of "userName": result = message.alias
    of "message": result = message.text
    else: result = ""

  proc add*(self: ChatMessageList, message: Message) =
    if self.messageIndex.hasKey(message.id): return # duplicated msg

    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len)
    self.messageIndex[message.id] = self.messages.len
    self.messages.add(message)
    self.endInsertRows()

  proc add*(self: ChatMessageList, messages: seq[Message]) =
    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len)
    for message in messages:
      if self.messageIndex.hasKey(message.id): continue
      self.messageIndex[message.id] = self.messages.len
      self.messages.add(message)
    self.endInsertRows()

  proc clear*(self: ChatMessageList) =
    self.beginResetModel()
    self.messages = @[]
    self.endResetModel()

  proc markMessageAsSent*(self: ChatMessageList, messageId: string)=
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.messages.len, 0, nil)
    for m in self.messages.mitems:
      if m.id == messageId:
        m.outgoingStatus = "sent"
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.OutgoingStatus.int])

  
  proc updateUsernames*(self: ChatMessageList, contacts: seq[Profile]) =
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.messages.len, 0, nil)

    # TODO: change this once the contact list uses a table
    for c in contacts:
      for m in self.messages.mitems:
        if m.fromAuthor == c.id:
          m.alias = userNameOrAlias(c)

    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.Username.int])



