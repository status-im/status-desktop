import NimQml, Tables,
  ../../../status/[status, ens]
type
  CommunityMembersRoles {.pure.} = enum
    UserName = UserRole + 1,
    PubKey = UserRole + 2,
    Identicon = UserRole + 3

QtObject:
  type
    CommunityMembersView* = ref object of QAbstractListModel
      status: Status
      members*: seq[string]

  proc setup(self: CommunityMembersView) = self.QAbstractListModel.setup

  proc delete(self: CommunityMembersView) =
    self.members = @[]
    self.QAbstractListModel.delete

  proc newCommunityMembersView*(status: Status): CommunityMembersView =
    new(result, delete)
    result.members = @[]
    result.status = status
    result.setup()

  proc setMembers*(self: CommunityMembersView, members: seq[string]) =
    self.beginResetModel()
    self.members = members
    self.endResetModel()

  proc getIndexFromPubKey*(self: CommunityMembersView, pubKey: string): int =
    var i = 0
    for memberPubKey in self.members:
      if (memberPubKey == pubKey):
        return i
      i = i + 1
    return -1

  proc removeMember*(self: CommunityMembersView, pubKey: string) =
    let memberIndex = self.getIndexFromPubKey(pubKey)
    if (memberIndex == -1):
      return
    self.beginRemoveRows(newQModelIndex(), memberIndex, memberIndex)
    self.members.delete(memberIndex)
    self.endRemoveRows()

  method rowCount(self: CommunityMembersView, index: QModelIndex = nil): int = self.members.len

  proc userName(self: CommunityMembersView, pk: string, alias: string): string =
    if self.status.chat.contacts.hasKey(pk):
      result = ens.userNameOrAlias(self.status.chat.contacts[pk])
    else:
      result = alias

  proc identicon(self: CommunityMembersView, pk: string): string =
    if self.status.chat.contacts.hasKey(pk):
      result = self.status.chat.contacts[pk].identicon
    else:
      result = self.status.accounts.generateIdenticon(pk)

  proc alias(self: CommunityMembersView, pk: string): string =
    if self.status.chat.contacts.hasKey(pk):
      result = self.status.chat.contacts[pk].alias
    else:
      result = self.status.accounts.generateAlias(pk)

  proc localNickname(self: CommunityMembersView, pk: string): string =
    if self.status.chat.contacts.hasKey(pk):
      result = self.status.chat.contacts[pk].localNickname

  method data(self: CommunityMembersView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.members.len:
      return

    let communityMemberPubkey = self.members[index.row]
    let communityMemberRole = role.CommunityMembersRoles
    case communityMemberRole:
      of CommunityMembersRoles.UserName: result = newQVariant(self.userName(communityMemberPubkey, self.alias(communityMemberPubkey)))
      of CommunityMembersRoles.PubKey: result = newQVariant(communityMemberPubkey)
      of CommunityMembersRoles.Identicon: result = newQVariant(self.identicon(communityMemberPubkey))
      
  proc rowData(self: CommunityMembersView, index: int, column: string): string {.slot.} =
    if (index >= self.members.len):
      return
    let communityMemberPubkey = self.members[index]
    case column:
      of "alias": result = self.alias(communityMemberPubkey)
      of "address": result = communityMemberPubkey
      of "identicon": result = self.identicon(communityMemberPubkey)
      of "localNickname": result = self.localNickname(communityMemberPubkey)
      of "ensName": result = self.userName(communityMemberPubkey, self.alias(communityMemberPubkey))

  method roleNames(self: CommunityMembersView): Table[int, string] =
    {
      CommunityMembersRoles.UserName.int:"userName",
      CommunityMembersRoles.PubKey.int:"pubKey",
      CommunityMembersRoles.Identicon.int:"identicon"
    }.toTable

  proc triggerUpdate*(self: CommunityMembersView) =
    self.beginResetModel()
    self.endResetModel()