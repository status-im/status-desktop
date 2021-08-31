import NimQml, Tables
import ../../../status/types as status_types
import ../../../status/[chat/chat, ens, status, settings]

type
  CommunityMembersRoles {.pure.} = enum
    UserName = UserRole + 1,
    PubKey = UserRole + 2,
    Identicon = UserRole + 3,
    LastSeen = UserRole + 4,
    StatusType = UserRole + 5,
    Online = UserRole + 6,
    SortKey = UserRole + 7

QtObject:
  type
    CommunityMembersView* = ref object of QAbstractListModel
      status: Status
      myPubKey: string
      community*: Community

  proc setup(self: CommunityMembersView) = self.QAbstractListModel.setup

  proc delete(self: CommunityMembersView) =
    self.QAbstractListModel.delete

  proc newCommunityMembersView*(status: Status): CommunityMembersView =
    new(result, delete)
    result.status = status
    result.setup()

  proc setCommunity*(self: CommunityMembersView, community: Community) =
    self.beginResetModel()
    self.community = community
    self.myPubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")
    self.endResetModel()

  proc getIndexFromPubKey*(self: CommunityMembersView, pubKey: string): int =
    var i = 0
    for memberPubKey in self.community.members:
      if (memberPubKey == pubKey):
        return i
      i = i + 1
    return -1

  proc removeMember*(self: CommunityMembersView, pubKey: string) =
    let memberIndex = self.getIndexFromPubKey(pubKey)
    if (memberIndex == -1):
      return
    self.beginRemoveRows(newQModelIndex(), memberIndex, memberIndex)
    self.community.members.delete(memberIndex)
    self.endRemoveRows()

  method rowCount(self: CommunityMembersView, index: QModelIndex = nil): int = 
    self.community.members.len

  proc userName(self: CommunityMembersView, pk: string, alias: string): string =
    if self.status.chat.contacts.hasKey(pk):
      if self.status.chat.contacts[pk].localNickname != "":
        result = self.status.chat.contacts[pk].localNickname
      else:
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

  proc memberLastSeen(self: CommunityMembersView, pk: string): string =
    if self.community.memberStatus.hasKey(pk):
      result = $self.community.memberStatus[pk].clock
    else:
      result = "0"

  proc memberStatus(self: CommunityMembersView, pk: string): int =
    if self.community.memberStatus.hasKey(pk):
      result = self.community.memberStatus[pk].statusType.int

  proc isOnline(self: CommunityMembersView, pk: string): bool =
    if self.myPubKey == pk:
      return true
    if self.community.memberStatus.hasKey(pk):
      result = self.community.memberStatus[pk].statusType.int == StatusUpdateType.Online.int

  proc sortKey(self: CommunityMembersView, pk: string): string =
    let name = self.userName(pk, self.alias(pk))
    if self.isOnline(pk):
      return "A" & name
    return "B" & name

  method data(self: CommunityMembersView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.community.members.len:
      return

    let communityMemberPubkey = self.community.members[index.row]
    let communityMemberRole = role.CommunityMembersRoles
    case communityMemberRole:
      of CommunityMembersRoles.UserName: result = newQVariant(self.userName(communityMemberPubkey, self.alias(communityMemberPubkey)))
      of CommunityMembersRoles.PubKey: result = newQVariant(communityMemberPubkey)
      of CommunityMembersRoles.Identicon: result = newQVariant(self.identicon(communityMemberPubkey))
      of CommunityMembersRoles.LastSeen: result = newQVariant(self.memberLastSeen(communityMemberPubkey))
      of CommunityMembersRoles.StatusType: result = newQVariant(self.memberStatus(communityMemberPubkey))
      of CommunityMembersRoles.Online: result = newQVariant(self.isOnline(communityMemberPubkey))
      of CommunityMembersRoles.SortKey: result = newQVariant(self.sortKey(communityMemberPubkey))

  proc rowData(self: CommunityMembersView, index: int, column: string): string {.slot.} =
    if (index >= self.community.members.len):
      return
    let communityMemberPubkey = self.community.members[index]
    case column:
      of "alias": result = self.alias(communityMemberPubkey)
      of "publicKey": result = communityMemberPubkey
      of "identicon": result = self.identicon(communityMemberPubkey)
      of "localName": result = self.localNickname(communityMemberPubkey)
      of "userName": result = self.userName(communityMemberPubkey, self.alias(communityMemberPubkey))

  method roleNames(self: CommunityMembersView): Table[int, string] =
    {
      CommunityMembersRoles.UserName.int:"userName",
      CommunityMembersRoles.PubKey.int:"pubKey",
      CommunityMembersRoles.Identicon.int:"identicon",
      CommunityMembersRoles.LastSeen.int:"lastSeen",
      CommunityMembersRoles.StatusType.int:"statusType",
      CommunityMembersRoles.Online.int:"online",
      CommunityMembersRoles.SortKey.int:"sortKey"
    }.toTable

  proc triggerUpdate*(self: CommunityMembersView) =
    self.beginResetModel()
    self.endResetModel()
