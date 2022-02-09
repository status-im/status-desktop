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
    isIdenticon: bool
    color: string
    description: string
    hasUnreadMessages: bool
    notificationsCount: int
    muted: bool
    position: int

  proc delete*(self: ChatDetails) =
    self.QObject.delete

  proc newChatDetails*(): ChatDetails =
    new(result, delete)
    result.QObject.setup

  proc setChatDetails*(self: ChatDetails, id: string, `type`: int, belongsToCommunity, isUsersListAvailable: bool,
      name, icon: string, isIdenticon: bool, color, description: string, hasUnreadMessages: bool,
      notificationsCount: int, muted: bool, position: int) =
    self.id = id
    self.`type` = `type`
    self.belongsToCommunity = belongsToCommunity
    self.isUsersListAvailable = isUsersListAvailable
    self.name = name
    self.icon = icon
    self.isIdenticon = isIdenticon
    self.color = color
    self.description = description
    self.hasUnreadMessages = hasUnreadMessages
    self.notificationsCount = notificationsCount
    self.muted = muted
    self.position = position

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

  proc getIsIdenticon(self: ChatDetails): bool {.slot.} =
    return self.isIdenticon
  QtProperty[bool] isIdenticon:
    read = getIsIdenticon
    notify = iconChanged

  proc setIcon*(self: ChatDetails, icon: string, isIdenticon: bool) = # this is not a slot
    self.icon = icon
    self.isIdenticon = isIdenticon
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
