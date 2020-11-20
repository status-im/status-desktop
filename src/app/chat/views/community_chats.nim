import NimQml, Tables,
  ../../../status/[chat/chat, status]

type
  ChatMemberRoles {.pure.} = enum
    Id = UserRole + 1,
    Name = UserRole + 2,
    Description = UserRole + 3,
    Access = UserRole + 4

QtObject:
  type
    CommunityChatsList* = ref object of QAbstractListModel
      status: Status
      chats*: seq[CommunityChat]

  proc setup(self: CommunityChatsList) = self.QAbstractListModel.setup

  proc delete(self: CommunityChatsList) =
    self.chats = @[]
    self.QAbstractListModel.delete

  proc newCommunityChatsView*(status: Status): CommunityChatsList =
    new(result, delete)
    result.chats = @[]
    result.status = status
    result.setup()

  proc setChats*(self: CommunityChatsList, chats: seq[CommunityChat]) =
    self.beginResetModel()
    self.chats = chats
    self.endResetModel()

  method rowCount(self: CommunityChatsList, index: QModelIndex = nil): int = self.chats.len

  method data(self: CommunityChatsList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.chats.len:
      return

    let chat = self.chats[index.row]
    let chatMemberRole = role.ChatMemberRoles
    case chatMemberRole:
      of ChatMemberRoles.Id: result = newQVariant(chat.id)
      of ChatMemberRoles.Name: result = newQVariant(chat.name)
      of ChatMemberRoles.Description: result = newQVariant(chat.description)
      of ChatMemberRoles.Access: result = newQVariant(chat.access)

  method roleNames(self: CommunityChatsList): Table[int, string] =
    {
      ChatMemberRoles.Id.int:"id",
      ChatMemberRoles.Name.int:"name",
      ChatMemberRoles.Description.int: "description",
      ChatMemberRoles.Access.int: "access"
    }.toTable
