import NimQml, Tables
import ../../../status/chat/[chat, message]

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
      members*: seq[ChatMember]

  proc setup(self: ChatMembersView) = self.QAbstractListModel.setup

  proc delete(self: ChatMembersView) = self.QAbstractListModel.delete

  proc newChatMembersView*(): ChatMembersView =
    new(result, delete)
    result.members = @[]
    result.setup()

  proc setMembers*(self: ChatMembersView, members: seq[ChatMember]) =
    self.beginResetModel()
    self.members = members
    self.endResetModel()

  proc len*(self: ChatMembersView): int {.slot.} = self.members.len

  method rowCount(self: ChatMembersView, index: QModelIndex = nil): int = self.members.len

  method data(self: ChatMembersView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.members.len:
      return

    let chatMember = self.members[index.row]
    let chatMemberRole = role.ChatMemberRoles
    case chatMemberRole:
      of ChatMemberRoles.UserName: result = newQVariant(chatMember.userName)
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
