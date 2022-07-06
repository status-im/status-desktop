import NimQml
import section_item, user_item
import ../../../app_service/service/contacts/dto/contacts

QtObject:
  type ActiveSection* = ref object of QObject
    item: SectionItem

  proc setup(self: ActiveSection) =
    self.QObject.setup

  proc delete*(self: ActiveSection) =
    self.QObject.delete

  proc newActiveSection*(): ActiveSection =
    new(result, delete)
    result.setup

  proc membersChanged*(self: ActiveSection) {.signal.}
  proc pendingRequestsToJoinChanged*(self: ActiveSection) {.signal.}

  proc setActiveSectionData*(self: ActiveSection, item: SectionItem) =
    self.item = item
    self.membersChanged()
    self.pendingRequestsToJoinChanged()

  proc getId*(self: ActiveSection): string {.slot.} =
    return self.item.id

  QtProperty[string] id:
    read = getId

  proc getSectionType(self: ActiveSection): int {.slot.} =
    return self.item.sectionType.int

  QtProperty[int] sectionType:
    read = getSectionType

  proc getName(self: ActiveSection): string {.slot.} =
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getAmISectionAdmin(self: ActiveSection): bool {.slot.} =
    return self.item.amISectionAdmin

  QtProperty[bool] amISectionAdmin:
    read = getAmISectionAdmin

  proc description(self: ActiveSection): string {.slot.} =
    return self.item.description

  QtProperty[string] description:
    read = description

  proc introMessage(self: ActiveSection): string {.slot.} =
    return self.item.introMessage

  QtProperty[string] introMessage:
    read = introMessage

  proc outroMessage(self: ActiveSection): string {.slot.} =
    return self.item.outroMessage

  QtProperty[string] outroMessage:
    read = outroMessage

  proc getImage(self: ActiveSection): string {.slot.} =
    return self.item.image

  QtProperty[string] image:
    read = getImage

  proc getBannerImageData(self: ActiveSection): string {.slot.} =
    return self.item.bannerImageData

  QtProperty[string] bannerImageData:
    read = getBannerImageData

  proc getIcon(self: ActiveSection): string {.slot.} =
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: ActiveSection): string {.slot.} =
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getTags(self: ActiveSection): string {.slot.} =
    return self.item.tags

  QtProperty[string] tags:
    read = getTags

  proc getHasNotification(self: ActiveSection): bool {.slot.} =
    return self.item.hasNotification

  QtProperty[bool] hasNotification:
    read = getHasNotification

  proc getNotificationCount(self: ActiveSection): int {.slot.} =
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  proc canJoin(self: ActiveSection): bool {.slot.} =
    return self.item.canJoin

  QtProperty[bool] canJoin:
    read = canJoin

  proc canRequestAccess(self: ActiveSection): bool {.slot.} =
    return self.item.canRequestAccess

  QtProperty[bool] canRequestAccess:
    read = canRequestAccess

  proc canManageUsers(self: ActiveSection): bool {.slot.} =
    return self.item.canManageUsers

  QtProperty[bool] canManageUsers:
    read = canManageUsers

  proc getJoined(self: ActiveSection): bool {.slot.} =
    return self.item.joined

  QtProperty[bool] joined:
    read = getJoined

  proc getIsMember(self: ActiveSection): bool {.slot.} =
    return self.item.isMember

  QtProperty[bool] isMember:
    read = getIsMember

  proc access(self: ActiveSection): int {.slot.} =
    return self.item.access

  QtProperty[int] access:
    read = access

  proc ensOnly(self: ActiveSection): bool {.slot.} =
    return self.item.ensOnly

  QtProperty[bool] ensOnly:
    read = ensOnly

  proc historyArchiveSupportEnabled(self: ActiveSection): bool {.slot.} =
    return self.item.historyArchiveSupportEnabled

  QtProperty[bool] historyArchiveSupportEnabled:
    read = historyArchiveSupportEnabled

  proc pinMessageAllMembersEnabled(self: ActiveSection): bool {.slot.} =
    return self.item.pinMessageAllMembersEnabled

  QtProperty[bool] pinMessageAllMembersEnabled:
    read = pinMessageAllMembersEnabled

  proc members(self: ActiveSection): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.members)

  QtProperty[QVariant] members:
    read = members
    notify = membersChanged

  proc hasMember(self: ActiveSection, pubkey: string): bool {.slot.} =
    return self.item.hasMember(pubkey)

  proc setOnlineStatusForMember*(self: ActiveSection, pubKey: string,
      onlineStatus: OnlineStatus) =
    self.item.setOnlineStatusForMember(pubKey, onlineStatus)
    
  proc updateMember*(
      self: ActiveSection,
      pubkey: string,
      name: string,
      ensName: string,
      localNickname: string,
      alias: string,
      image: string,
      isContact: bool,
      isUntrustworthy: bool) =
    self.item.updateMember(pubkey, name, ensName, localNickname, alias, image, isContact,
      isUntrustworthy)

  proc pendingRequestsToJoin(self: ActiveSection): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.pendingRequestsToJoin)

  QtProperty[QVariant] pendingRequestsToJoin:
    read = pendingRequestsToJoin
    notify = pendingRequestsToJoinChanged
