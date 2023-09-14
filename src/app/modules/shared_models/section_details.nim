import NimQml
import section_item
import ../../../app_service/service/contacts/dto/contacts

import ../../../app_service/common/types

QtObject:
  type SectionDetails* = ref object of QObject
    item: SectionItem

  proc setup(self: SectionDetails) =
    self.QObject.setup

  proc delete*(self: SectionDetails) =
    self.QObject.delete

  proc newActiveSection*(): SectionDetails =
    new(result, delete)
    result.setup

  proc membersChanged*(self: SectionDetails) {.signal.}
  proc bannedMembersChanged*(self: SectionDetails) {.signal.}
  proc pendingRequestsToJoinChanged*(self: SectionDetails) {.signal.}
  proc pendingMemberRequestsChanged*(self: SectionDetails) {.signal.}
  proc declinedMemberRequestsChanged*(self: SectionDetails) {.signal.}
  proc communityTokensChanged*(self: SectionDetails) {.signal.}

  proc setActiveSectionData*(self: SectionDetails, item: SectionItem) =
    self.item = item
    self.membersChanged()
    self.bannedMembersChanged()
    self.pendingMemberRequestsChanged()
    self.declinedMemberRequestsChanged()
    self.pendingRequestsToJoinChanged()
    self.communityTokensChanged()

  proc getId*(self: SectionDetails): string {.slot.} =
    return self.item.id

  QtProperty[string] id:
    read = getId

  proc getSectionType(self: SectionDetails): int {.slot.} =
    return self.item.sectionType.int

  QtProperty[int] sectionType:
    read = getSectionType

  proc getName(self: SectionDetails): string {.slot.} =
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getMemberRole(self: SectionDetails): int {.slot.} =
    return self.item.memberRole.int

  QtProperty[int] memberRole:
    read = getMemberRole

  proc description(self: SectionDetails): string {.slot.} =
    return self.item.description

  QtProperty[string] description:
    read = description

  proc introMessage(self: SectionDetails): string {.slot.} =
    return self.item.introMessage

  QtProperty[string] introMessage:
    read = introMessage

  proc outroMessage(self: SectionDetails): string {.slot.} =
    return self.item.outroMessage

  QtProperty[string] outroMessage:
    read = outroMessage

  proc getImage(self: SectionDetails): string {.slot.} =
    return self.item.image

  QtProperty[string] image:
    read = getImage

  proc getBannerImageData(self: SectionDetails): string {.slot.} =
    return self.item.bannerImageData

  QtProperty[string] bannerImageData:
    read = getBannerImageData

  proc getIcon(self: SectionDetails): string {.slot.} =
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: SectionDetails): string {.slot.} =
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getTags(self: SectionDetails): string {.slot.} =
    return self.item.tags

  QtProperty[string] tags:
    read = getTags

  proc getHasNotification(self: SectionDetails): bool {.slot.} =
    return self.item.hasNotification

  QtProperty[bool] hasNotification:
    read = getHasNotification

  proc getNotificationCount(self: SectionDetails): int {.slot.} =
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  proc canJoin(self: SectionDetails): bool {.slot.} =
    return self.item.canJoin

  QtProperty[bool] canJoin:
    read = canJoin

  proc canRequestAccess(self: SectionDetails): bool {.slot.} =
    return self.item.canRequestAccess

  QtProperty[bool] canRequestAccess:
    read = canRequestAccess

  proc canManageUsers(self: SectionDetails): bool {.slot.} =
    return self.item.canManageUsers

  QtProperty[bool] canManageUsers:
    read = canManageUsers

  proc getJoined(self: SectionDetails): bool {.slot.} =
    return self.item.joined

  QtProperty[bool] joined:
    read = getJoined

  proc getIsMember(self: SectionDetails): bool {.slot.} =
    return self.item.isMember

  QtProperty[bool] isMember:
    read = getIsMember

  proc access(self: SectionDetails): int {.slot.} =
    return self.item.access

  QtProperty[int] access:
    read = access

  proc ensOnly(self: SectionDetails): bool {.slot.} =
    return self.item.ensOnly

  QtProperty[bool] ensOnly:
    read = ensOnly

  proc historyArchiveSupportEnabled(self: SectionDetails): bool {.slot.} =
    return self.item.historyArchiveSupportEnabled

  QtProperty[bool] historyArchiveSupportEnabled:
    read = historyArchiveSupportEnabled

  proc pinMessageAllMembersEnabled(self: SectionDetails): bool {.slot.} =
    return self.item.pinMessageAllMembersEnabled

  QtProperty[bool] pinMessageAllMembersEnabled:
    read = pinMessageAllMembersEnabled

  proc encrypted(self: SectionDetails): bool {.slot.} =
    return self.item.encrypted

  QtProperty[bool] encrypted:
    read = encrypted

  proc members(self: SectionDetails): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.members)

  QtProperty[QVariant] members:
    read = members
    notify = membersChanged


  proc bannedMembers(self: SectionDetails): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.bannedMembers)

  QtProperty[QVariant] bannedMembers:
    read = bannedMembers
    notify = bannedMembersChanged

  proc communityTokens(self: SectionDetails): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.communityTokens)

  QtProperty[QVariant] communityTokens:
    read = communityTokens
    notify = communityTokensChanged

  proc amIBanned(self: SectionDetails): bool {.slot.} =
    return self.item.amIBanned

  QtProperty[bool] amIBanned:
    read = amIBanned
    notify = bannedMembersChanged

  proc pendingMemberRequests(self: SectionDetails): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.pendingMemberRequests)

  QtProperty[QVariant] pendingMemberRequests:
    read = pendingMemberRequests
    notify = pendingMemberRequestsChanged


  proc declinedMemberRequests(self: SectionDetails): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.declinedMemberRequests)

  QtProperty[QVariant] declinedMemberRequests:
    read = declinedMemberRequests
    notify = declinedMemberRequestsChanged

  proc hasMember(self: SectionDetails, pubkey: string): bool {.slot.} =
    return self.item.hasMember(pubkey)

  proc setOnlineStatusForMember*(self: SectionDetails, pubKey: string,
      onlineStatus: OnlineStatus) =
    self.item.setOnlineStatusForMember(pubKey, onlineStatus)

  proc updateMember*(
      self: SectionDetails,
      pubkey: string,
      name: string,
      ensName: string,
      isEnsVerified: bool,
      localNickname: string,
      alias: string,
      image: string,
      isContact: bool,
      isVerified: bool,
      isUntrustworthy: bool) =
    self.item.updateMember(pubkey, name, ensName, isEnsVerified, localNickname, alias, image, isContact,
      isVerified, isUntrustworthy)

  proc pendingRequestsToJoin(self: SectionDetails): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.pendingRequestsToJoin)

  QtProperty[QVariant] pendingRequestsToJoin:
    read = pendingRequestsToJoin
    notify = pendingRequestsToJoinChanged
