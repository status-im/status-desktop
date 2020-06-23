import NimQml, Tables,
  ../../../status/[chat/chat, status, ens]

type
  ChatMemberRoles {.pure.} = enum
    UserName = UserRole + 1,
    PubKey = UserRole + 2,
    IsAdmin = UserRole + 3,
    Joined = UserRole + 4
    Identicon = UserRole + 5

QtObject:
  type
    ChatMembersView* = ref object of QAbstractListModel
      status: Status
      members*: seq[ChatMember]

  proc setup(self: ChatMembersView) = self.QAbstractListModel.setup

  proc delete(self: ChatMembersView) =
    self.members = @[]
    self.QAbstractListModel.delete

  proc newChatMembersView*(status: Status): ChatMembersView =
    new(result, delete)
    result.members = @[]
    result.status = status
    result.setup()

  proc setMembers*(self: ChatMembersView, members: seq[ChatMember]) =
    self.beginResetModel()
    self.members = members
    self.endResetModel()

  method rowCount(self: ChatMembersView, index: QModelIndex = nil): int = self.members.len

  proc userName(self: ChatMembersView, id: string, alias: string): string =
    if self.status.chat.contacts.hasKey(id):
      result = ens.userNameOrAlias(self.status.chat.contacts[id])
    else:
      result = alias

  method data(self: ChatMembersView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.members.len:
      return

    let chatMember = self.members[index.row]
    let chatMemberRole = role.ChatMemberRoles
    case chatMemberRole:
      of ChatMemberRoles.UserName: result = newQVariant(self.userName(chatMember.id, chatMember.userName))
      of ChatMemberRoles.PubKey: result = newQVariant(chatMember.id)
      of ChatMemberRoles.IsAdmin: result = newQVariant(chatMember.admin)
      of ChatMemberRoles.Joined: result = newQVariant(chatMember.joined)
      of ChatMemberRoles.Identicon: result = newQVariant(chatMember.identicon)

  method roleNames(self: ChatMembersView): Table[int, string] =
    {
      ChatMemberRoles.UserName.int:"userName",
      ChatMemberRoles.PubKey.int:"pubKey",
      ChatMemberRoles.IsAdmin.int: "isAdmin",
      ChatMemberRoles.Joined.int: "joined",
      ChatMemberRoles.Identicon.int: "identicon",
    }.toTable
