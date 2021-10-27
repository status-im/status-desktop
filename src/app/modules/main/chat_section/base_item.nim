type 
  BaseItem* {.pure inheritable.} = ref object of RootObj
    id: string
    name: string
    icon: string
    color: string
    description: string
    hasNotification: bool
    notificationsCount: int
    muted: bool
    active: bool

proc setup*(self: BaseItem, id, name, icon, color, description: string, hasNotification: bool, notificationsCount: int, 
  muted, active: bool) =
  self.id = id
  self.name = name
  self.icon = icon
  self.color = color
  self.description = description
  self.hasNotification = hasNotification
  self.notificationsCount = notificationsCount
  self.muted = muted
  self.active = active

proc initBaseItem*(id, name, icon, color, description: string, hasNotification: bool, notificationsCount: int, 
  muted, active: bool): BaseItem =
  result = BaseItem()
  result.setup(id, name, icon, color, description, hasNotification, notificationsCount, muted, active)

proc delete*(self: BaseItem) = 
  discard

method id*(self: BaseItem): string {.inline base.} = 
  self.id

method name*(self: BaseItem): string {.inline base.} = 
  self.name

method icon*(self: BaseItem): string {.inline base.} = 
  self.icon

method color*(self: BaseItem): string {.inline base.} = 
  self.color

method description*(self: BaseItem): string {.inline base.} = 
  self.description

method hasNotification*(self: BaseItem): bool {.inline base.} = 
  self.hasNotification

method `hasNotification=`*(self: var BaseItem, value: bool) {.inline base.} = 
  self.hasNotification = value

method notificationsCount*(self: BaseItem): int {.inline base.} = 
  self.notificationsCount

method `notificationsCount=`*(self: var BaseItem, value: int) {.inline base.} = 
  self.notificationsCount = value

method muted*(self: BaseItem): bool {.inline base.} = 
  self.muted

method `muted=`*(self: var BaseItem, value: bool) {.inline base.} = 
  self.muted = value

method active*(self: BaseItem): bool {.inline base.} = 
  self.active

method `active=`*(self: var BaseItem, value: bool) {.inline base.} = 
  self.active = value