import NimQml, Tables, strformat
import  ./member_item
import ../../global/global_singleton

type
  MembersRoles {.pure.} = enum
    PubKey = UserRole + 1
    # LastSeen = UserRole,
    # StatusType = UserRole,
    # Online = UserRole,
    # SortKey = UserRole

QtObject:
  type
    MembersModel* = ref object of QAbstractListModel
      members*: seq[MemberItem]

  proc setup(self: MembersModel) = self.QAbstractListModel.setup

  proc delete(self: MembersModel) =
    self.QAbstractListModel.delete

  proc newMembersModel*(members: seq[MemberItem]): MembersModel =
    new(result, delete)
    result.members = members
    result.setup()

  proc `$`*(self: MembersModel): string =
    for i in 0 ..< self.members.len:
      result &= fmt"""MembersModel:
      [{i}]:({$self.members[i]})
      """

  proc getIndexFromPubKey*(self: MembersModel, pubKey: string): int =
    var i = 0
    for member in self.members:
      if (member.id == pubKey):
        return i
      i = i + 1
    return -1

  proc hasMember*(self: MembersModel, pubkey: string): bool =
    for member in self.members:
      if (member.id == pubkey):
        return true
    return false

  proc removeMember*(self: MembersModel, pubKey: string) =
    let memberIndex = self.getIndexFromPubKey(pubKey)
    if (memberIndex == -1):
      return
    self.beginRemoveRows(newQModelIndex(), memberIndex, memberIndex)
    self.members.delete(memberIndex)
    self.endRemoveRows()

  proc countChanged*(self: MembersModel) {.signal.}
  proc count*(self: MembersModel): int {.slot.} =
    self.members.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: MembersModel, index: QModelIndex = nil): int = 
    self.members.len

  # proc memberStatus(self: MembersModel, pk: string): int =
  #   if self.membersStatus.hasKey(pk):
  #     result = self.membersStatus[pk].statusType.int

  # proc isOnline(self: MembersModel, pk: string): bool =
  #   if self.myPubKey == pk:
  #     return true
  #   if self.membersStatus.hasKey(pk):
  #     result = self.membersStatus[pk].statusType.int == StatusUpdateType.Online.int

  # proc sortKey(self: MembersModel, pk: string): string =
  #   let name = self.userName(pk, self.alias(pk))
  #   if self.isOnline(pk):
  #     return "A" & name
  #   return "B" & name

  method data(self: MembersModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.members.len:
      return

    let member = self.members[index.row]
    let memberRole = role.MembersRoles
    case memberRole:
      of MembersRoles.PubKey: result = newQVariant(member.id)
      # of MembersRoles.LastSeen: result = newQVariant(self.memberLastSeen(member.id))
      # of MembersRoles.StatusType: result = newQVariant(self.memberStatus(member.id))
      # of MembersRoles.Online: result = newQVariant(self.isOnline(member.id))
      # of MembersRoles.SortKey: result = newQVariant(self.sortKey(member.id))

  method roleNames(self: MembersModel): Table[int, string] =
    {
      MembersRoles.PubKey.int:"pubKey"
      # MembersRoles.LastSeen.int:"lastSeen",
      # MembersRoles.StatusType.int:"statusType",
      # MembersRoles.Online.int:"online",
      # MembersRoles.SortKey.int:"sortKey"
    }.toTable

  # proc triggerUpdate*(self: MembersModel) =
  #   self.beginResetModel()
  #   self.endResetModel()
