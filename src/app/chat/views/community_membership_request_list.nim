import NimQml, Tables, chronicles
import ../../../status/chat/[chat, message]
import ../../../status/status
import ../../../status/ens
import ../../../status/accounts
import strutils

type
  CommunityMembershipRequestRoles {.pure.} = enum
    Id = UserRole + 1,
    PublicKey = UserRole + 2
    ChatId = UserRole + 3
    CommunityId = UserRole + 4
    State = UserRole + 5
    Our = UserRole + 6

QtObject:
  type
    CommunityMembershipRequestList* = ref object of QAbstractListModel
      communityMembershipRequests*: seq[CommunityMembershipRequest]

  proc setup(self: CommunityMembershipRequestList) = self.QAbstractListModel.setup

  proc delete(self: CommunityMembershipRequestList) = 
    self.communityMembershipRequests = @[]
    self.QAbstractListModel.delete

  proc newCommunityMembershipRequestList*(): CommunityMembershipRequestList =
    new(result, delete)
    result.communityMembershipRequests = @[]
    result.setup()

  method rowCount*(self: CommunityMembershipRequestList, index: QModelIndex = nil): int = self.communityMembershipRequests.len

  method data(self: CommunityMembershipRequestList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.communityMembershipRequests.len:
      return

    let communityMembershipRequestItem = self.communityMembershipRequests[index.row]
    let communityMembershipRequestItemRole = role.CommunityMembershipRequestRoles
    case communityMembershipRequestItemRole:
      of CommunityMembershipRequestRoles.Id: result = newQVariant(communityMembershipRequestItem.id.string)
      of CommunityMembershipRequestRoles.PublicKey: result = newQVariant(communityMembershipRequestItem.publicKey.string)
      of CommunityMembershipRequestRoles.ChatId: result = newQVariant(communityMembershipRequestItem.chatId.string)
      of CommunityMembershipRequestRoles.CommunityId: result = newQVariant(communityMembershipRequestItem.communityId.string)
      of CommunityMembershipRequestRoles.State: result = newQVariant(communityMembershipRequestItem.state.int)
      of CommunityMembershipRequestRoles.Our: result = newQVariant(communityMembershipRequestItem.our.string)

  method roleNames(self: CommunityMembershipRequestList): Table[int, string] =
    {
      CommunityMembershipRequestRoles.Id.int: "id",
      CommunityMembershipRequestRoles.PublicKey.int: "publicKey",
      CommunityMembershipRequestRoles.ChatId.int: "chatId",
      CommunityMembershipRequestRoles.CommunityId.int: "communityId",
      CommunityMembershipRequestRoles.State.int: "state",
      CommunityMembershipRequestRoles.Our.int: "our"
    }.toTable

  proc nbRequestsChanged*(self: CommunityMembershipRequestList) {.signal.}

  proc nbRequests*(self: CommunityMembershipRequestList): int {.slot.} = result = self.communityMembershipRequests.len
  
  QtProperty[int] nbRequests:
    read = nbRequests
    notify = nbRequestsChanged

  proc setNewData*(self: CommunityMembershipRequestList, communityMembershipRequestList: seq[CommunityMembershipRequest]) =
    self.beginResetModel()
    self.communityMembershipRequests = communityMembershipRequestList
    self.endResetModel()
    self.nbRequestsChanged()

  proc addCommunityMembershipRequestItemToList*(self: CommunityMembershipRequestList, communityMemberphipRequest: CommunityMembershipRequest) =
    self.beginInsertRows(newQModelIndex(), self.communityMembershipRequests.len, self.communityMembershipRequests.len)
    self.communityMembershipRequests.add(communityMemberphipRequest)
    self.endInsertRows()
    self.nbRequestsChanged()

  proc removeCommunityMembershipRequestItemFromList*(self: CommunityMembershipRequestList, id: string) =
    let idx = self.communityMembershipRequests.findIndexById(id)
    self.beginRemoveRows(newQModelIndex(), idx, idx)
    self.communityMembershipRequests.delete(idx)
    self.endRemoveRows()
    self.nbRequestsChanged()

  proc getCommunityMembershipRequestById*(self: CommunityMembershipRequestList, communityMembershipRequestId: string): CommunityMembershipRequest =
    for communityMembershipRequest in self.communityMembershipRequests:
      if communityMembershipRequest.id == communityMembershipRequestId:
        return communityMembershipRequest
