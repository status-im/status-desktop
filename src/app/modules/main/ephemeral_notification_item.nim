import ../../core/notifications/details

type
  EphemeralNotificationType* {.pure.} = enum
    Default = 0
    Success
    Danger

type
  Item* = object
    id: int64
    timestamp: string
    title: string
    durationInMs: int
    subTitle: string
    icon: string
    iconColor: string
    loading: bool
    ephNotifType: EphemeralNotificationType
    url: string
    actionType: int
    actionData: string
    details: NotificationDetails

proc initItem*(id: int64,
    title: string,
    durationInMs = 0,
    subTitle = "",
    icon = "",
    iconColor = "",
    loading = false,
    ephNotifType = EphemeralNotificationType.Default,
    url = "",
    actionType = 0, # It means, no action enabled
    actionData = "",
    details: NotificationDetails): Item =
  result = Item()
  result.id = id
  result.timestamp = $id
  result.durationInMs = durationInMs
  result.title = title
  result.subTitle = subTitle
  result.icon = icon
  result.iconColor = iconColor
  result.loading = loading
  result.ephNotifType = ephNotifType
  result.url = url
  result.actionType = actionType
  result.actionData = actionData
  result.details = details

proc id*(self: Item): int64 =
  self.id

proc timestamp*(self: Item): string =
  self.timestamp

proc title*(self: Item): string =
  self.title

proc durationInMs*(self: Item): int =
  self.durationInMs
  
proc subTitle*(self: Item): string =
  self.subTitle

proc icon*(self: Item): string =
  self.icon

proc iconColor*(self: Item): string =
  self.iconColor

proc loading*(self: Item): bool =
  self.loading

proc ephNotifType*(self: Item): EphemeralNotificationType =
  self.ephNotifType

proc url*(self: Item): string =
  self.url

proc actionType*(self: Item): int =
  self.actionType

proc actionData*(self: Item): string =
  self.actionData

proc details*(self: Item): NotificationDetails =
  self.details