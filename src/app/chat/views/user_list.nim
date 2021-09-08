import NimQml, Tables, json, chronicles, sequtils
import status/status
import status/accounts
import status/chat as status_chat
import status/chat/[chat]
import status/ens
import status/types/[message]

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
    username*: string
    alias*: string
    localName: string
    lastSeen: string
    identicon: string

QtObject:
  type
    UserListView* = ref object of QAbstractListModel
      status: Status
      users*: seq[string]
      userDetails*: OrderedTable[string, User]

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

  proc rowData(self: UserListView, index: int, column: string): string {.slot.} =
    if (index >= self.users.len):
      return

    let publicKey = self.users[index]
    case column:
      of "publicKey": result = publicKey
      of "userName": result = self.userDetails[publicKey].username
      of "lastSeen": result = self.userDetails[publicKey].lastSeen
      of "alias": result = self.userDetails[publicKey].alias
      of "localName": result = self.userDetails[publicKey].localName
      of "identicon": result = self.userdetails[publicKey].identicon

  method rowCount*(self: UserListView, index: QModelIndex = nil): int = self.users.len

  method data(self: UserListView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.users.len:
      return

    let pubkey = self.users[index.row]

    case role.UserListRoles:
      of UserListRoles.UserName: result = newQVariant(self.userDetails[pubkey].username)
      of UserListRoles.LastSeen: result = newQVariant(self.userDetails[pubkey].lastSeen)
      of UserListRoles.Alias: result = newQVariant(self.userDetails[pubkey].alias)
      of UserListRoles.LocalName: result = newQVariant(self.userDetails[pubkey].localName)
      of UserListRoles.PublicKey: result = newQVariant(pubkey)
      of UserListRoles.Identicon: result = newQVariant(self.userdetails[pubkey].identicon)

  method roleNames(self: UserListView): Table[int, string] =
    {
      UserListRoles.UserName.int:"userName",
      UserListRoles.LastSeen.int:"lastSeen",
      UserListRoles.PublicKey.int:"publicKey",
      UserListRoles.Alias.int:"alias",
      UserListRoles.LocalName.int:"localName",
      UserListRoles.Identicon.int:"identicon"
    }.toTable

  proc add*(self: UserListView, members: seq[ChatMember]) =
    # Adding chat members
    for m in members:
      let pk = m.id
      if self.userDetails.hasKey(pk): continue

      var userName: string
      var alias: string
      var identicon: string
      var localName: string

      if self.status.chat.contacts.hasKey(pk):
        userName = ens.userNameOrAlias(self.status.chat.contacts[pk])
        alias = self.status.chat.contacts[pk].alias
        identicon = self.status.chat.contacts[pk].identicon
        localName = self.status.chat.contacts[pk].localNickname
      else:
        userName = m.username
        alias = m.username
        identicon = m.identicon
        localName = ""

      self.beginInsertRows(newQModelIndex(), self.users.len, self.users.len)
      self.userDetails[pk] = User(
          userName: userName,
          alias: alias,
          localName: localName,
          lastSeen: "0",
          identicon: identicon
      )
      self.users.add(pk)
      self.endInsertRows()

    # Checking for removed members
    var toDelete: seq[string]
    for userPublicKey in self.users:
      var found = false
      for m in members:
        if m.id == userPublicKey:
          found = true
          break
      if not found:
        toDelete.add(userPublicKey)

    # Removing deleted members
    if toDelete.len > 0:
      for pkToDelete in toDelete:
        let idx = self.users.find(pkToDelete)
        self.beginRemoveRows(newQModelIndex(), idx, idx)
        self.users.del(idx)
        self.userDetails.del(pkToDelete)
        self.endRemoveRows()

  proc add*(self: UserListView, message: Message) =
    if self.userDetails.hasKey(message.fromAuthor):
        self.userDetails[message.fromAuthor] = User(
            userName: message.userName,
            alias: message.alias,
            localName: message.localName,
            lastSeen: message.timestamp,
            identicon: message.identicon
        )
        var index = 0
        for publicKey in self.users:
          if publicKey == message.fromAuthor:
            break
          
          index+=1

        let topLeft = self.createIndex(index, index, nil)
        let bottomRight = self.createIndex(index, index, nil)
        self.dataChanged(topLeft, bottomRight, @[
          UserListRoles.UserName.int,
          UserListRoles.LastSeen.int,
          UserListRoles.Alias.int,
          UserListRoles.LocalName.int,
          UserListRoles.Identicon.int
        ])
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
