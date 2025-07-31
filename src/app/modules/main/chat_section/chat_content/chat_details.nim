import nimqml
import ../../../../../app_service/common/types


QtObject:
  type ChatDetails* = ref object of QObject
    # fixed props
    id: string
    `type`: int
    belongsToCommunity: bool
    isUsersListAvailable: bool
    # changable props
    name: string
    icon: string
    color: string
    description: string
    emoji: string
    hasUnreadMessages: bool
    notificationsCount: int
    highlight: bool
    muted: bool
    position: int
    trustStatus: TrustStatus
    isContact: bool
    active: bool
    blocked: bool
    canPost: bool
    canView: bool
    canPostReactions: bool
    hideIfPermissionsNotMet: bool
    missingEncryptionKey: bool
    requiresPermissions: bool

  proc delete*(self: ChatDetails) =
    self.QObject.delete

  proc newChatDetails*(): ChatDetails =
    new(result, delete)
    result.QObject.setup

  proc setChatDetails*(
      self: ChatDetails,
      id: string,
      `type`: int,
      belongsToCommunity,
      isUsersListAvailable: bool,
      name,
      icon:string,
      color, description,
      emoji: string,
      hasUnreadMessages: bool,
      notificationsCount: int,
      highlight, muted: bool,
      position: int,
      trustStatus: TrustStatus,
      isContact: bool = false,
      blocked: bool = false,
      canPost: bool = true,
      canView: bool = true,
      canPostReactions: bool = true,
      hideIfPermissionsNotMet: bool,
      missingEncryptionKey: bool,
      requiresPermissions: bool,
    ) =
    self.id = id
    self.`type` = `type`
    self.belongsToCommunity = belongsToCommunity
    self.isUsersListAvailable = isUsersListAvailable
    self.name = name
    self.icon = icon
    self.color = color
    self.emoji = emoji
    self.description = description
    self.hasUnreadMessages = hasUnreadMessages
    self.notificationsCount = notificationsCount
    self.highlight = highlight
    self.muted = muted
    self.position = position
    self.trustStatus = trustStatus
    self.isContact = isContact
    self.active = false
    self.blocked = blocked
    self.canPost = canPost
    self.canView = canView
    self.canPostReactions = canPostReactions
    self.hideIfPermissionsNotMet = hideIfPermissionsNotMet
    self.missingEncryptionKey = missingEncryptionKey
    self.requiresPermissions = requiresPermissions

  proc getId(self: ChatDetails): string {.slot.} =
    return self.id
  QtProperty[string] id:
    read = getId

  proc getType(self: ChatDetails): int {.slot.} =
    return self.`type`
  QtProperty[int] type:
    read = getType

  proc getBelongsToCommunity(self: ChatDetails): bool {.slot.} =
    return self.belongsToCommunity
  QtProperty[bool] belongsToCommunity:
    read = getBelongsToCommunity

  proc getIsUsersListAvailable(self: ChatDetails): bool {.slot.} =
    return self.isUsersListAvailable
  QtProperty[bool] isUsersListAvailable:
    read = getIsUsersListAvailable

  proc nameChanged(self: ChatDetails) {.signal.}
  proc getName(self: ChatDetails): string {.slot.} =
    return self.name
  QtProperty[string] name:
    read = getName
    notify = nameChanged

  proc setName*(self: ChatDetails, value: string) = # this is not a slot
    if self.name == value:
      return
    self.name = value
    self.nameChanged()

  proc iconChanged(self: ChatDetails) {.signal.}
  proc getIcon(self: ChatDetails): string {.slot.} =
    return self.icon
  QtProperty[string] icon:
    read = getIcon
    notify = iconChanged

  proc setIcon*(self: ChatDetails, icon: string) = # this is not a slot
    if self.icon == icon:
      return
    self.icon = icon
    self.iconChanged()

  proc colorChanged(self: ChatDetails) {.signal.}
  proc getColor(self: ChatDetails): string {.slot.} =
    return self.color
  QtProperty[string] color:
    read = getColor
    notify = colorChanged

  proc setColor*(self: ChatDetails, value: string) = # this is not a slot
    if self.color == value:
      return
    self.color = value
    self.colorChanged()

  proc emojiChanged(self: ChatDetails) {.signal.}
  proc getEmoji(self: ChatDetails): string {.slot.} =
    return self.emoji
  QtProperty[string] emoji:
    read = getEmoji
    notify = emojiChanged

  proc setEmoji*(self: ChatDetails, value: string) = # this is not a slot
    if self.emoji == value:
      return
    self.emoji = value
    self.emojiChanged()

  proc descriptionChanged(self: ChatDetails) {.signal.}
  proc getDescription(self: ChatDetails): string {.slot.} =
    return self.description
  QtProperty[string] description:
    read = getDescription
    notify = descriptionChanged

  proc setDescription*(self: ChatDetails, value: string) = # this is not a slot
    if self.description == value:
      return
    self.description = value
    self.descriptionChanged()

  proc hasUnreadMessagesChanged(self: ChatDetails) {.signal.}
  proc getHasUnreadMessages(self: ChatDetails): bool {.slot.} =
    return self.hasUnreadMessages
  QtProperty[bool] hasUnreadMessages:
    read = getHasUnreadMessages
    notify = hasUnreadMessages

  proc setHasUnreadMessages*(self: ChatDetails, value: bool) = # this is not a slot
    if self.hasUnreadMessages == value:
      return
    self.hasUnreadMessages = value
    self.hasUnreadMessagesChanged()

  proc notificationCountChanged(self: ChatDetails) {.signal.}
  proc getNotificationCount(self: ChatDetails): int {.slot.} =
    return self.notificationsCount
  QtProperty[int] notificationCount:
    read = getNotificationCount
    notify = notificationCountChanged

  proc setNotificationCount*(self: ChatDetails, value: int) = # this is not a slot
    if self.notificationsCount == value:
      return
    self.notificationsCount = value
    self.notificationCountChanged()

  proc highlightChanged(self: ChatDetails) {.signal.}
  proc getHighlight*(self: ChatDetails): bool {.slot.} =
    return self.highlight
  QtProperty[bool] highlight:
    read = getHighlight
    notify = highlightChanged

  proc setHighlight*(self: ChatDetails, value: bool) = # this is not a slot
    if self.highlight == value:
      return
    self.highlight = value
    self.highlightChanged()

  proc mutedChanged(self: ChatDetails) {.signal.}
  proc getMuted(self: ChatDetails): bool {.slot.} =
    return self.muted
  QtProperty[bool] muted:
    read = getMuted
    notify = mutedChanged

  proc setMuted*(self: ChatDetails, value: bool) = # this is not a slot
    if self.muted == value:
      return
    self.muted = value
    self.mutedChanged()

  proc positionChanged(self: ChatDetails) {.signal.}
  proc getPosition(self: ChatDetails): int {.slot.} =
    return self.position
  QtProperty[int] position:
    read = getPosition
    notify = positionChanged

  proc setPotion*(self: ChatDetails, value: int) = # this is not a slot
    if self.position == value:
      return
    self.position = value
    self.positionChanged()

  proc isMutualContactChanged(self: ChatDetails) {.signal.}
  proc getIsMutualContact(self: ChatDetails): bool {.slot.} =
    return self.isContact
  QtProperty[bool] isContact:
    read = getIsMutualContact
    notify = isMutualContactChanged

  proc setIsMutualContact*(self: ChatDetails, value: bool) = # this is not a slot
    if self.isContact == value:
      return
    self.isContact = value
    self.isMutualContactChanged()

  proc isUntrustworthyChanged(self: ChatDetails) {.signal.}
  proc getIsUntrustworthy(self: ChatDetails): bool {.slot.} =
    return self.trustStatus == TrustStatus.Untrustworthy
  QtProperty[bool] isUntrustworthy:
    read = getIsUntrustworthy
    notify = isUntrustworthyChanged

  proc trustStatusChanged(self: ChatDetails) {.signal.}
  proc getTrustStatus(self: ChatDetails): int {.slot.} =
    return self.trustStatus.int
  QtProperty[int] trustStatus:
    read = getTrustStatus
    notify = trustStatusChanged

  proc setTrustStatus*(self: ChatDetails, value: TrustStatus) = # this is not a slot
    if self.trustStatus == value:
      return
    self.trustStatus = value
    self.trustStatusChanged()
    self.isUntrustworthyChanged()

  proc activeChanged(self: ChatDetails) {.signal.}
  proc isActive(self: ChatDetails): bool {.slot.} =
    return self.active
  QtProperty[bool] active:
    read = isActive
    notify = activeChanged

  proc setActive*(self: ChatDetails, value: bool) =
    if self.active == value:
      return
    self.active = value
    self.activeChanged()

  proc blockedChanged(self: ChatDetails) {.signal.}
  proc getBlocked(self: ChatDetails): bool {.slot.} =
    return self.blocked
  QtProperty[bool] blocked:
    read = getBlocked
    notify = blockedChanged

  proc setBlocked*(self: ChatDetails, value: bool) =
    if self.blocked == value:
      return
    self.blocked = value
    self.blockedChanged()

  proc canPostChanged(self: ChatDetails) {.signal.}
  proc getCanPost(self: ChatDetails): bool {.slot.} =
    return self.canPost
  QtProperty[bool] canPost:
    read = getCanPost
    notify = canPostChanged

  proc setCanPost*(self: ChatDetails, value: bool) =
    if self.canPost == value:
      return
    self.canPost = value
    self.canPostChanged()

  proc canViewChanged(self: ChatDetails) {.signal.}
  proc getCanView(self: ChatDetails): bool {.slot.} =
    return self.canView
  QtProperty[bool] canView:
    read = getCanView
    notify = canViewChanged

  proc setCanView*(self: ChatDetails, value: bool) =
    if self.canView == value:
      return
    self.canView = value
    self.canViewChanged()

  proc canPostReactionsChanged(self: ChatDetails) {.signal.}
  proc getCanPostReactions(self: ChatDetails): bool {.slot.} =
    return self.canPostReactions
  QtProperty[bool] canPostReactions:
    read = getCanPostReactions
    notify = canPostReactionsChanged

  proc setCanPostReactions*(self: ChatDetails, value: bool) =
    if self.canPostReactions == value:
      return
    self.canPostReactions = value
    self.canPostReactionsChanged()
  
  proc hideIfPermissionsNotMetChanged(self: ChatDetails) {.signal.}
  proc getHideIfPermissionsNotMet(self: ChatDetails): bool {.slot.} =
    return self.hideIfPermissionsNotMet
  QtProperty[bool] hideIfPermissionsNotMet:
    read = getHideIfPermissionsNotMet
    notify = hideIfPermissionsNotMetChanged

  proc setHideIfPermissionsNotMet*(self: ChatDetails, value: bool) =
    if self.hideIfPermissionsNotMet == value:
      return
    self.hideIfPermissionsNotMet = value
    self.hideIfPermissionsNotMetChanged()

  proc missingEncryptionKeyChanged(self: ChatDetails) {.signal.}
  proc getMissingEncryptionKey(self: ChatDetails): bool {.slot.} =
    return self.missingEncryptionKey
  QtProperty[bool] missingEncryptionKey:
    read = getMissingEncryptionKey
    notify = missingEncryptionKeyChanged

  proc setMissingEncryptionKey*(self: ChatDetails, value: bool) =
    if self.missingEncryptionKey == value:
      return
    self.missingEncryptionKey = value
    self.missingEncryptionKeyChanged()

  proc requiresPermissionsChanged(self: ChatDetails) {.signal.}
  proc getRequiresPermissions*(self: ChatDetails): bool {.slot.} =
    return self.requiresPermissions
  QtProperty[bool] requiresPermissions:
    read = getRequiresPermissions
    notify = requiresPermissionsChanged

  proc setRequiresPermissions*(self: ChatDetails, value: bool) =
    if self.requiresPermissions == value:
      return
    self.requiresPermissions = value
    self.requiresPermissionsChanged()
