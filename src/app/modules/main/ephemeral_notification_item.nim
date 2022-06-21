import ../../core/notifications/details

type
  EphemeralNotificationType* {.pure.} = enum
    Default = 0
    Success

type
  Item* = object
    id: int64
    title: string
    durationInMs: int
    subTitle: string
    icon: string
    loading: bool
    ephNotifType: EphemeralNotificationType
    url: string
    details: NotificationDetails

proc initItem*(id: int64,
    title: string,
    durationInMs = 0,
    subTitle = "",
    icon = "",
    loading = false,
    ephNotifType = EphemeralNotificationType.Default,
    url = "",
    details: NotificationDetails): Item =
  result = Item()
  result.id = id
  result.durationInMs = durationInMs
  result.title = title
  result.subTitle = subTitle
  result.icon = icon
  result.loading = loading
  result.ephNotifType = ephNotifType
  result.url = url
  result.details = details

proc id*(self: Item): int64 =
  self.id

proc title*(self: Item): string =
  self.title

proc durationInMs*(self: Item): int =
  self.durationInMs
  
proc subTitle*(self: Item): string =
  self.subTitle

proc icon*(self: Item): string =
  self.icon

proc loading*(self: Item): bool =
  self.loading

proc ephNotifType*(self: Item): EphemeralNotificationType =
  self.ephNotifType

proc url*(self: Item): string =
  self.url

proc details*(self: Item): NotificationDetails =
  self.details