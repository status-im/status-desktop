import NimQml
import section_item

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

  proc getImage(self: ActiveSection): string {.slot.} =
    return self.item.image

  QtProperty[string] image:
    read = getImage

  proc getIcon(self: ActiveSection): string {.slot.} =
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: ActiveSection): string {.slot.} =
    return self.item.color

  QtProperty[string] color:
    read = getColor

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

  proc updateMember*(
      self: ActiveSection,
      pubkey: string,
      name: string,
      ensName: string,
      localNickname: string,
      alias: string,
      image: string,
      isIdenticon: bool) =
    self.item.updateMember(pubkey, name, ensName, localNickname, alias, image, isIdenticon)

  proc pendingRequestsToJoin(self: ActiveSection): QVariant {.slot.} =
    if (self.item.id == ""):
      # FIXME (Jo) I don't know why but the Item is sometimes empty and doing anything here crashes the app
      return newQVariant("")
    return newQVariant(self.item.pendingRequestsToJoin)

  QtProperty[QVariant] pendingRequestsToJoin:
    read = pendingRequestsToJoin
    notify = pendingRequestsToJoinChanged
