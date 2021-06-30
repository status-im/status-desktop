import NimQml, Tables, json, chronicles, sequtils
import ../../../status/status
import ../../../status/accounts
import ../../../status/chat
import ../../../status/chat/[message]
import strutils

type
  UserListRoles {.pure.} = enum
    UserName = UserRole + 1
    LastSeen = UserRole + 2
    PublicKey = UserRole + 3
    Alias = UserRole + 4
    LocalName = UserRole + 5
    Identicon = UserRole + 6

  User = object
    username: string
    alias: string
    localName: string
    lastSeen: string
    identicon: string

QtObject:
  type
    UserListView* = ref object of QAbstractListModel
      status: Status
      users: seq[string]
      userDetails: OrderedTable[string, User]

  proc delete(self: UserListView) =
    self.userDetails.clear()
    self.QAbstractListModel.delete

  proc setup(self: UserListView) =
    self.QAbstractListModel.setup

  proc newUserListView*(status: Status): UserListView =
    new(result, delete)
    result.userDetails = initOrderedTable[string, User]()
    result.users = @[]
    result.status = status
    result.setup

  method rowCount*(self: UserListView, index: QModelIndex = nil): int = self.users.len

  method data(self: UserListView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.users.len:
      return
    
    let user = self.users[index.row]

    case role.UserListRoles:
      of UserListRoles.UserName: result = newQVariant(self.userDetails[user].userName)
      of UserListRoles.LastSeen: result = newQVariant(self.userDetails[user].lastSeen)
      of UserListRoles.Alias: result = newQVariant(self.userDetails[user].alias)
      of UserListRoles.LocalName: result = newQVariant(self.userDetails[user].localName)
      of UserListRoles.PublicKey: result = newQVariant(user)
      of UserListRoles.Identicon: result = newQVariant(self.userdetails[user].identicon)

  method roleNames(self: UserListView): Table[int, string] =
    {
      UserListRoles.UserName.int:"userName",
      UserListRoles.LastSeen.int:"lastSeen",
      UserListRoles.PublicKey.int:"publicKey",
      UserListRoles.Alias.int:"alias",
      UserListRoles.LocalName.int:"localName",
      UserListRoles.Identicon.int:"identicon"
    }.toTable

  proc add*(self: UserListView, message: Message) =
    if self.userDetails.hasKey(message.fromAuthor):
        self.beginResetModel()
        self.userDetails[message.fromAuthor] = User(
            userName: message.userName,
            alias: message.alias,
            localName: message.localName,
            lastSeen: message.timestamp,
            identicon: message.identicon
        )
        self.endResetModel()
    else:
        self.beginInsertRows(newQModelIndex(), self.users.len, self.users.len)
        self.userDetails[message.fromAuthor] = User(
            userName: message.userName,
            alias: message.alias,
            localName: message.localName,
            lastSeen: message.timestamp,
            identicon: message.identicon
        )
        self.users.add(message.fromAuthor)
        self.endInsertRows()

  proc triggerUpdate*(self: UserListView) {.slot.} =
    self.beginResetModel()
    self.endResetModel()

  proc updateUsernames*(self: UserListView, publicKey, userName, alias, localName: string) =
    if not self.userDetails.hasKey(publicKey): return

    var i = -1
    var found = -1
    for u in self.users:
      i = i + 1
      if u == publicKey:
        found = i

    if found == -1: return

    self.userDetails[publicKey].username = userName
    self.userDetails[publicKey].alias = alias
    self.userDetails[publicKey].localName = localName

    let topLeft = self.createIndex(found, 0, nil)
    let bottomRight = self.createIndex(found, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[UserListRoles.Username.int, UserListRoles.Alias.int, UserListRoles.Localname.int])
