import NimQml
import ../../../../../app_service/common/types
import ../item as chat_item


QtObject:
  type ChatDetails* = ref object of QObject
    chatItem: ChatItem
    belongsToCommunity: bool
    isUsersListAvailable: bool
    isMutualContact: bool

  proc delete*(self: ChatDetails) =
    self.QObject.delete

  proc newChatDetails*(): ChatDetails =
    new(result, delete)
    result.QObject.setup
    result.chatItem = ChatItem()

  proc setChatDetails*(
      self: ChatDetails,
      chatItem: ChatItem,
      belongsToCommunity: bool,
      isUsersListAvailable: bool,
      isMutualContact: bool,
    ) =
    self.chatItem = chatItem
    self.belongsToCommunity = belongsToCommunity
    self.isUsersListAvailable = isUsersListAvailable
    self.isMutualContact = isMutualContact

  proc getId(self: ChatDetails): string {.slot.} =
    return self.chatItem.id
  QtProperty[string] id:
    read = getId

  proc getType(self: ChatDetails): int {.slot.} =
    return self.chatItem.`type`
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
    return self.chatItem.name
  QtProperty[string] name:
    read = getName
    notify = nameChanged

  proc setName*(self: ChatDetails, value: string) = # this is not a slot
    if self.chatItem.name == value:
      return
    self.chatItem.name = value
    self.nameChanged()

  proc iconChanged(self: ChatDetails) {.signal.}
  proc getIcon(self: ChatDetails): string {.slot.} =
    return self.chatItem.icon
  QtProperty[string] icon:
    read = getIcon
    notify = iconChanged

  proc setIcon*(self: ChatDetails, icon: string) = # this is not a slot
    if self.chatItem.icon == icon:
      return
    self.chatItem.icon = icon
    self.iconChanged()

  proc colorChanged(self: ChatDetails) {.signal.}
  proc getColor(self: ChatDetails): string {.slot.} =
    return self.chatItem.color
  QtProperty[string] color:
    read = getColor
    notify = colorChanged

  proc setColor*(self: ChatDetails, value: string) = # this is not a slot
    if self.chatItem.color == value:
      return
    self.chatItem.color = value
    self.colorChanged()

  proc emojiChanged(self: ChatDetails) {.signal.}
  proc getEmoji(self: ChatDetails): string {.slot.} =
    return self.chatItem.emoji
  QtProperty[string] emoji:
    read = getEmoji
    notify = emojiChanged

  proc setEmoji*(self: ChatDetails, value: string) = # this is not a slot
    if self.chatItem.emoji == value:
      return
    self.chatItem.emoji = value
    self.emojiChanged()

  proc descriptionChanged(self: ChatDetails) {.signal.}
  proc getDescription(self: ChatDetails): string {.slot.} =
    return self.chatItem.description
  QtProperty[string] description:
    read = getDescription
    notify = descriptionChanged

  proc setDescription*(self: ChatDetails, value: string) = # this is not a slot
    if self.chatItem.description == value:
      return
    self.chatItem.description = value
    self.descriptionChanged()

  proc hasUnreadMessagesChanged(self: ChatDetails) {.signal.}
  proc getHasUnreadMessages(self: ChatDetails): bool {.slot.} =
    return self.chatItem.hasUnreadMessages
  QtProperty[bool] hasUnreadMessages:
    read = getHasUnreadMessages
    notify = hasUnreadMessages

  proc setHasUnreadMessages*(self: ChatDetails, value: bool) = # this is not a slot
    if self.chatItem.hasUnreadMessages == value:
      return
    self.chatItem.hasUnreadMessages = value
    self.hasUnreadMessagesChanged()

  proc notificationCountChanged(self: ChatDetails) {.signal.}
  proc getNotificationCount(self: ChatDetails): int {.slot.} =
    return self.chatItem.notificationsCount
  QtProperty[int] notificationCount:
    read = getNotificationCount
    notify = notificationCountChanged

  proc setNotificationCount*(self: ChatDetails, value: int) = # this is not a slot
    if self.chatItem.notificationsCount == value:
      return
    self.chatItem.notificationsCount = value
    self.notificationCountChanged()

  proc highlightChanged(self: ChatDetails) {.signal.}
  proc getHighlight*(self: ChatDetails): bool {.slot.} =
    return self.chatItem.highlight
  QtProperty[bool] highlight:
    read = getHighlight
    notify = highlightChanged

  proc setHighlight*(self: ChatDetails, value: bool) = # this is not a slot
    if self.chatItem.highlight == value:
      return
    self.chatItem.highlight = value
    self.highlightChanged()

  proc mutedChanged(self: ChatDetails) {.signal.}
  proc getMuted(self: ChatDetails): bool {.slot.} =
    return self.chatItem.muted
  QtProperty[bool] muted:
    read = getMuted
    notify = mutedChanged

  proc setMuted*(self: ChatDetails, value: bool) = # this is not a slot
    if self.chatItem.muted == value:
      return
    self.chatItem.muted = value
    self.mutedChanged()

  proc positionChanged(self: ChatDetails) {.signal.}
  proc getPosition(self: ChatDetails): int {.slot.} =
    return self.chatItem.position
  QtProperty[int] position:
    read = getPosition
    notify = positionChanged

  proc setPosition*(self: ChatDetails, value: int) = # this is not a slot
    if self.chatItem.position == value:
      return
    self.chatItem.position = value
    self.positionChanged()

  proc isMutualContactChanged(self: ChatDetails) {.signal.}
  proc getIsMutualContact(self: ChatDetails): bool {.slot.} =
    return self.isMutualContact
  QtProperty[bool] isContact:
    read = getIsMutualContact
    notify = isMutualContactChanged

  proc setIsMutualContact*(self: ChatDetails, value: bool) = # this is not a slot
    if self.isMutualContact == value:
      return
    self.isMutualContact = value
    self.isMutualContactChanged()

  proc isUntrustworthyChanged(self: ChatDetails) {.signal.}
  proc getIsUntrustworthy(self: ChatDetails): bool {.slot.} =
    return self.chatItem.trustStatus == TrustStatus.Untrustworthy
  QtProperty[bool] isUntrustworthy:
    read = getIsUntrustworthy
    notify = isUntrustworthyChanged

  proc trustStatusChanged(self: ChatDetails) {.signal.}
  proc getTrustStatus(self: ChatDetails): int {.slot.} =
    return self.chatItem.trustStatus.int
  QtProperty[int] trustStatus:
    read = getTrustStatus
    notify = trustStatusChanged

  proc setTrustStatus*(self: ChatDetails, value: TrustStatus) = # this is not a slot
    if self.chatItem.trustStatus == value:
      return
    self.chatItem.trustStatus = value
    self.trustStatusChanged()
    self.isUntrustworthyChanged()

  proc activeChanged(self: ChatDetails) {.signal.}
  proc isActive(self: ChatDetails): bool {.slot.} =
    return self.chatItem.active
  QtProperty[bool] active:
    read = isActive
    notify = activeChanged

  proc setActive*(self: ChatDetails, value: bool) =
    if self.chatItem.active == value:
      return
    self.chatItem.active = value
    self.activeChanged()

  proc blockedChanged(self: ChatDetails) {.signal.}
  proc getBlocked(self: ChatDetails): bool {.slot.} =
    return self.chatItem.blocked
  QtProperty[bool] blocked:
    read = getBlocked
    notify = blockedChanged

  proc setBlocked*(self: ChatDetails, value: bool) =
    if self.chatItem.blocked == value:
      return
    self.chatItem.blocked = value
    self.blockedChanged()

  proc canPostChanged(self: ChatDetails) {.signal.}
  proc getCanPost(self: ChatDetails): bool {.slot.} =
    return self.chatItem.canPost
  QtProperty[bool] canPost:
    read = getCanPost
    notify = canPostChanged

  proc setCanPost*(self: ChatDetails, value: bool) =
    if self.chatItem.canPost == value:
      return
    self.chatItem.canPost = value
    self.canPostChanged()

  proc canViewChanged(self: ChatDetails) {.signal.}
  proc getCanView(self: ChatDetails): bool {.slot.} =
    return self.chatItem.canView
  QtProperty[bool] canView:
    read = getCanView
    notify = canViewChanged

  proc setCanView*(self: ChatDetails, value: bool) =
    if self.chatItem.canView == value:
      return
    self.chatItem.canView = value
    self.canViewChanged()

  proc canPostReactionsChanged(self: ChatDetails) {.signal.}
  proc getCanPostReactions(self: ChatDetails): bool {.slot.} =
    return self.chatItem.canPostReactions
  QtProperty[bool] canPostReactions:
    read = getCanPostReactions
    notify = canPostReactionsChanged

  proc setCanPostReactions*(self: ChatDetails, value: bool) =
    if self.chatItem.canPostReactions == value:
      return
    self.chatItem.canPostReactions = value
    self.canPostReactionsChanged()
  
  proc hideIfPermissionsNotMetChanged(self: ChatDetails) {.signal.}
  proc getHideIfPermissionsNotMet(self: ChatDetails): bool {.slot.} =
    return self.chatItem.hideIfPermissionsNotMet
  QtProperty[bool] hideIfPermissionsNotMet:
    read = getHideIfPermissionsNotMet
    notify = hideIfPermissionsNotMetChanged

  proc setHideIfPermissionsNotMet*(self: ChatDetails, value: bool) =
    if self.chatItem.hideIfPermissionsNotMet == value:
      return
    self.chatItem.hideIfPermissionsNotMet = value
    self.hideIfPermissionsNotMetChanged()

  proc missingEncryptionKeyChanged(self: ChatDetails) {.signal.}
  proc getMissingEncryptionKey(self: ChatDetails): bool {.slot.} =
    return self.chatItem.missingEncryptionKey
  QtProperty[bool] missingEncryptionKey:
    read = getMissingEncryptionKey
    notify = missingEncryptionKeyChanged

  proc setMissingEncryptionKey*(self: ChatDetails, value: bool) =
    if self.chatItem.missingEncryptionKey == value:
      return
    self.chatItem.missingEncryptionKey = value
    self.missingEncryptionKeyChanged()

  proc requiresPermissionsChanged(self: ChatDetails) {.signal.}
  proc getRequiresPermissions*(self: ChatDetails): bool {.slot.} =
    return self.chatItem.requiresPermissions
  QtProperty[bool] requiresPermissions:
    read = getRequiresPermissions
    notify = requiresPermissionsChanged

  proc setRequiresPermissions*(self: ChatDetails, value: bool) =
    if self.chatItem.requiresPermissions == value:
      return
    self.chatItem.requiresPermissions = value
    self.requiresPermissionsChanged()

  proc updateChatDetails*(self: ChatDetails, chatItem: ChatItem) =
    self.setName(chatItem.name)
    self.setIcon(chatItem.icon)
    self.setColor(chatItem.color)
    self.setEmoji(chatItem.emoji)
    self.setDescription(chatItem.description)
    self.setHasUnreadMessages(chatItem.hasUnreadMessages)
    self.setNotificationCount(chatItem.notificationsCount)
    self.setHighlight(chatItem.highlight)
    self.setMuted(chatItem.muted)
    self.setPosition(chatItem.position)
    self.setTrustStatus(chatItem.trustStatus)
    self.setActive(chatItem.active)
    self.setBlocked(chatItem.blocked)
    self.setCanPost(chatItem.canPost)
    self.setCanView(chatItem.canView)
    self.setCanPostReactions(chatItem.canPostReactions)
    self.setHideIfPermissionsNotMet(chatItem.hideIfPermissionsNotMet)
    self.setMissingEncryptionKey(chatItem.missingEncryptionKey)
    self.setRequiresPermissions(chatItem.requiresPermissions)