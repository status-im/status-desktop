import NimQml, std/wrapnils
import ../../../status/[chat/chat, status]
import channels_list
import ../../../eventemitter
import community_members_list
import community_membership_request_list

QtObject:
  type CommunityItemView* = ref object of QObject
    communityItem*: Community
    communityMembershipRequestList*: CommunityMembershipRequestList
    chats*: ChannelsList
    members*: CommunityMembersView
    status*: Status
    active*: bool

  proc setup(self: CommunityItemView) =
    self.QObject.setup

  proc delete*(self: CommunityItemView) =
    if not self.chats.isNil: self.chats.delete
    self.QObject.delete

  proc newCommunityItemView*(status: Status): CommunityItemView =
    new(result, delete)
    result = CommunityItemView()
    result.status = status
    result.active = false
    result.chats = newChannelsList(status)
    result.communityMembershipRequestList = newCommunityMembershipRequestList()
    result.members = newCommunityMembersView(status)
    result.setup

  proc setCommunityItem*(self: CommunityItemView, communityItem: Community) =
    self.communityItem = communityItem
    self.chats.setChats(communityItem.chats)
    self.members.setMembers(communityItem.members)
    self.communityMembershipRequestList.setNewData(communityItem.membershipRequests)

  proc activeChanged*(self: CommunityItemView) {.signal.}

  proc setActive*(self: CommunityItemView, value: bool) {.slot.} =
    self.active = value
    self.status.events.emit("communityActiveChanged", CommunityActiveChangedArgs(active: value))
    self.activeChanged()

  proc nbMembersChanged*(self: CommunityItemView) {.signal.}

  proc removeMember*(self: CommunityItemView, pubKey: string) =
    self.members.removeMember(pubKey)
    self.nbMembersChanged()

  proc active*(self: CommunityItemView): bool {.slot.} = result = ?.self.active
  
  QtProperty[bool] active:
    read = active
    write = setActive
    notify = activeChanged

  proc id*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.id
  
  QtProperty[string] id:
    read = id

  proc name*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.name
  
  QtProperty[string] name:
    read = name

  proc description*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.description
  
  QtProperty[string] description:
    read = description

  proc access*(self: CommunityItemView): int {.slot.} = result = ?.self.communityItem.access
  
  QtProperty[int] access:
    read = access

  proc admin*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.admin
  
  QtProperty[bool] admin:
    read = admin

  proc joined*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.joined
  
  QtProperty[bool] joined:
    read = joined

  proc verified*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.verified
  
  QtProperty[bool] verified:
    read = verified

  proc ensOnly*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.ensOnly
  
  QtProperty[bool] ensOnly:
    read = ensOnly

  proc canRequestAccess*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.canRequestAccess
  
  QtProperty[bool] canRequestAccess:
    read = canRequestAccess

  proc canManageUsers*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.canManageUsers
  
  QtProperty[bool] canManageUsers:
    read = canManageUsers

  proc canJoin*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.canJoin
  
  QtProperty[bool] canJoin:
    read = canJoin

  proc isMember*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.isMember
  
  QtProperty[bool] isMember:
    read = isMember

  proc nbMembers*(self: CommunityItemView): int {.slot.} = result = ?.self.communityItem.members.len
  
  QtProperty[int] nbMembers:
    read = nbMembers
    notify = nbMembersChanged

  proc getChats*(self: CommunityItemView): QVariant {.slot.} =
    result = newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChats

  proc getMembers*(self: CommunityItemView): QVariant {.slot.} =
    result = newQVariant(self.members)

  QtProperty[QVariant] members:
    read = getMembers

  proc getCommunityMembershipRequest*(self: CommunityItemView): QVariant {.slot.} =
    result = newQVariant(self.communityMembershipRequestList)

  QtProperty[QVariant] communityMembershipRequests:
    read = getCommunityMembershipRequest

  proc thumbnailImage*(self: CommunityItemView): string {.slot.} =
    if (self.communityItem.communityImage.isNil):
        return ""
    result = self.communityItem.communityImage.thumbnail

  QtProperty[string] thumbnailImage:
    read = thumbnailImage

  proc largeImage*(self: CommunityItemView): string {.slot.} =
    if (self.communityItem.communityImage.isNil):
        return ""
    result = self.communityItem.communityImage.large

  QtProperty[string] largeImage:
    read = largeImage