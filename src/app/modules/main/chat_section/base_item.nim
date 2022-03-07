type
  BaseItem* {.pure inheritable.} = ref object of RootObj
    id: string
    name: string
    `type`: int
    amIChatAdmin: bool
    icon: string
    isIdenticon: bool
    color: string
    emoji: string
    description: string
    hasUnreadMessages: bool
    notificationsCount: int
    muted: bool
    blocked: bool
    active: bool
    position: int
    categoryId: string
    highlight: bool

proc setup*(self: BaseItem, id, name, icon: string, isIdenticon: bool, color, emoji, description: string,
  `type`: int, amIChatAdmin: bool, hasUnreadMessages: bool, notificationsCount: int, muted, blocked, active: bool,
    position: int, categoryId: string = "", highlight: bool = false) =
  self.id = id
  self.name = name
  self.amIChatAdmin = amIChatAdmin
  self.icon = icon
  self.isIdenticon = isIdenticon
  self.color = color
  self.emoji = emoji
  self.description = description
  self.`type` = `type`
  self.hasUnreadMessages = hasUnreadMessages
  self.notificationsCount = notificationsCount
  self.muted = muted
  self.blocked = blocked
  self.active = active
  self.position = position
  self.categoryId = categoryId
  self.highlight = highlight

proc initBaseItem*(id, name, icon: string, isIdenticon: bool, color, emoji, description: string, `type`: int,
    amIChatAdmin: bool, hasUnreadMessages: bool, notificationsCount: int, muted, blocked, active: bool,
    position: int, categoryId: string = "", highlight: bool = false): BaseItem =
  result = BaseItem()
  result.setup(id, name, icon, isIdenticon, color, emoji, description, `type`, amIChatAdmin,
  hasUnreadMessages, notificationsCount, muted, blocked, active, position, categoryId, highlight)

proc delete*(self: BaseItem) =
  discard

method id*(self: BaseItem): string {.inline base.} =
  self.id

method name*(self: BaseItem): string {.inline base.} =
  self.name

method `name=`*(self: var BaseItem, value: string) {.inline base.} =
  self.name = value

method amIChatAdmin*(self: BaseItem): bool {.inline base.} =
  self.amIChatAdmin

method icon*(self: BaseItem): string {.inline base.} =
  self.icon

method `icon=`*(self: var BaseItem, value: string) {.inline base.} =
  self.icon = value

method isIdenticon*(self: BaseItem): bool {.inline base.} =
  self.isIdenticon

method `isIdenticon=`*(self: var BaseItem, value: bool) {.inline base.} =
  self.isIdenticon = value

method color*(self: BaseItem): string {.inline base.} =
  self.color

method emoji*(self: BaseItem): string {.inline base.} =
  self.emoji

method `emoji=`*(self: var BaseItem, value: string) {.inline base.} =
  self.emoji = value

method description*(self: BaseItem): string {.inline base.} =
  self.description

method `description=`*(self: var BaseItem, value: string) {.inline base.} =
  self.description = value

method type*(self: BaseItem): int {.inline base.} =
  self.`type`

method hasUnreadMessages*(self: BaseItem): bool {.inline base.} =
  self.hasUnreadMessages

method `hasUnreadMessages=`*(self: var BaseItem, value: bool) {.inline base.} =
  self.hasUnreadMessages = value

method notificationsCount*(self: BaseItem): int {.inline base.} =
  self.notificationsCount

method `notificationsCount=`*(self: var BaseItem, value: int) {.inline base.} =
  self.notificationsCount = value

method muted*(self: BaseItem): bool {.inline base.} =
  self.muted

method `muted=`*(self: var BaseItem, value: bool) {.inline base.} =
  self.muted = value

method blocked*(self: BaseItem): bool {.inline base.} =
  self.blocked

method `blocked=`*(self: var BaseItem, value: bool) {.inline base.} =
  self.blocked = value

method active*(self: BaseItem): bool {.inline base.} =
  self.active

method `active=`*(self: var BaseItem, value: bool) {.inline base.} =
  self.active = value

method position*(self: BaseItem): int {.inline base.} =
  self.position

method `position=`*(self: var BaseItem, value: int) {.inline base.} =
  self.position = value

method categoryId*(self: BaseItem): string {.inline base.} =
  self.categoryId

method `categoryId=`*(self: var BaseItem, value: string) {.inline base.} =
  self.categoryId = value

method highlight*(self: BaseItem): bool {.inline base.} =
  self.highlight

method `highlight=`*(self: var BaseItem, value: bool) {.inline base.} =
  self.highlight = value
