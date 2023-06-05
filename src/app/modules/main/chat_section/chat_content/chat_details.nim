import NimQml


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
    muted: bool
    position: int
    isUntrustworthy: bool
    isContact: bool
    active: bool
    blocked: bool

  proc delete*(self: ChatDetails) =
    self.QObject.delete

  proc newChatDetails*(): ChatDetails =
    new(result, delete)
    result.QObject.setup

  proc setChatDetails*(self: ChatDetails, id: string, `type`: int, belongsToCommunity,
      isUsersListAvailable: bool, name, icon: string, color, description,
      emoji: string, hasUnreadMessages: bool, notificationsCount: int, muted: bool, position: int,
      isUntrustworthy: bool, isContact: bool = false, blocked: bool = false) =
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
    self.muted = muted
    self.position = position
    self.isUntrustworthy = isUntrustworthy
    self.isContact = isContact
    self.active = false
    self.blocked = blocked

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
    self.name = value
    self.nameChanged()

  proc iconChanged(self: ChatDetails) {.signal.}
  proc getIcon(self: ChatDetails): string {.slot.} =
    return self.icon
  QtProperty[string] icon:
    read = getIcon
    notify = iconChanged

  proc setIcon*(self: ChatDetails, icon: string) = # this is not a slot
    self.icon = icon
    self.iconChanged()

  proc colorChanged(self: ChatDetails) {.signal.}
  proc getColor(self: ChatDetails): string {.slot.} =
    return self.color
  QtProperty[string] color:
    read = getColor
    notify = colorChanged

  proc setColor*(self: ChatDetails, value: string) = # this is not a slot
    self.color = value
    self.colorChanged()

  proc emojiChanged(self: ChatDetails) {.signal.}
  proc getEmoji(self: ChatDetails): string {.slot.} =
    return self.emoji
  QtProperty[string] emoji:
    read = getEmoji
    notify = emojiChanged

  proc setEmoji*(self: ChatDetails, value: string) = # this is not a slot
    self.emoji = value
    self.emojiChanged()

  proc descriptionChanged(self: ChatDetails) {.signal.}
  proc getDescription(self: ChatDetails): string {.slot.} =
    return self.description
  QtProperty[string] description:
    read = getDescription
    notify = descriptionChanged

  proc setDescription*(self: ChatDetails, value: string) = # this is not a slot
    self.description = value
    self.descriptionChanged()

  proc hasUnreadMessagesChanged(self: ChatDetails) {.signal.}
  proc getHasUnreadMessages(self: ChatDetails): bool {.slot.} =
    return self.hasUnreadMessages
  QtProperty[bool] hasUnreadMessages:
    read = getHasUnreadMessages
    notify = hasUnreadMessages

  proc setHasUnreadMessages*(self: ChatDetails, value: bool) = # this is not a slot
    self.hasUnreadMessages = value
    self.hasUnreadMessagesChanged()

  proc notificationCountChanged(self: ChatDetails) {.signal.}
  proc getNotificationCount(self: ChatDetails): int {.slot.} =
    return self.notificationsCount
  QtProperty[int] notificationCount:
    read = getNotificationCount
    notify = notificationCountChanged

  proc setNotificationCount*(self: ChatDetails, value: int) = # this is not a slot
    self.notificationsCount = value
    self.notificationCountChanged()

  proc mutedChanged(self: ChatDetails) {.signal.}
  proc getMuted(self: ChatDetails): bool {.slot.} =
    return self.muted
  QtProperty[bool] muted:
    read = getMuted
    notify = mutedChanged

  proc setMuted*(self: ChatDetails, value: bool) = # this is not a slot
    self.muted = value
    self.mutedChanged()

  proc positionChanged(self: ChatDetails) {.signal.}
  proc getPosition(self: ChatDetails): int {.slot.} =
    return self.position
  QtProperty[int] position:
    read = getPosition
    notify = positionChanged

  proc setPotion*(self: ChatDetails, value: int) = # this is not a slot
    self.position = value
    self.positionChanged()

  proc isMutualContactChanged(self: ChatDetails) {.signal.}
  proc getIsMutualContact(self: ChatDetails): bool {.slot.} =
    return self.isContact
  QtProperty[bool] isContact:
    read = getIsMutualContact
    notify = isMutualContactChanged

  proc setIsMutualContact*(self: ChatDetails, value: bool) = # this is not a slot
    self.isContact = value
    self.isMutualContactChanged()

  proc isUntrustworthyChanged(self: ChatDetails) {.signal.}
  proc getIsUntrustworthy(self: ChatDetails): bool {.slot.} =
    return self.isUntrustworthy
  QtProperty[bool] isUntrustworthy:
    read = getIsUntrustworthy
    notify = isUntrustworthyChanged

  proc setIsUntrustworthy*(self: ChatDetails, value: bool) = # this is not a slot
    self.isUntrustworthy = value
    self.isUntrustworthyChanged()

  proc activeChanged(self: ChatDetails) {.signal.}
  proc isActive(self: ChatDetails): bool {.slot.} =
    return self.active
  QtProperty[bool] active:
    read = isActive
    notify = activeChanged

  proc setActive*(self: ChatDetails, value: bool) =
    self.active = value
    self.activeChanged()

  proc blockedChanged(self: ChatDetails) {.signal.}
  proc getBlocked(self: ChatDetails): bool {.slot.} =
    return self.blocked
  QtProperty[bool] blocked:
    read = getBlocked
    notify = blockedChanged

  proc setBlocked*(self: ChatDetails, value: bool) =
    self.blocked = value
    self.blockedChanged()
