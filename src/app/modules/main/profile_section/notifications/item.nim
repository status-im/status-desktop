import ../../../../../app_service/service/settings/dto/settings

type Type* {.pure.} = enum
  Community
  OneToOneChat
  GroupChat

type Item* = ref object
  id: string
  name: string
  image: string
  color: string
  joinedTimestamp: int64
  itemType: Type
  muteAllMessages: bool
  personalMentions: string
  globalMentions: string
  otherMessages: string

proc initItem*(
    id, name, image, color: string,
    joinedTimestamp: int64,
    itemType: Type,
    muteAllMessages = false,
    personalMentions = VALUE_NOTIF_SEND_ALERTS,
    globalMentions = VALUE_NOTIF_SEND_ALERTS,
    otherMessages = VALUE_NOTIF_TURN_OFF,
): Item =
  result = Item()
  result.id = id
  result.name = name
  result.image = image
  result.color = color
  result.joinedTimestamp = joinedTimestamp
  result.itemType = itemType
  result.muteAllMessages = muteAllMessages
  result.personalMentions = personalMentions
  result.globalMentions = globalMentions
  result.otherMessages = otherMessages

proc id*(self: Item): string =
  return self.id

proc name*(self: Item): string =
  return self.name

proc `name=`*(self: Item, value: string) =
  self.name = value

proc image*(self: Item): string =
  return self.image

proc `image=`*(self: Item, value: string) =
  self.image = value

proc color*(self: Item): string =
  self.color

proc `color=`*(self: Item, value: string) =
  self.color = value

proc joinedTimestamp*(self: Item): int64 =
  return self.joinedTimestamp

proc itemType*(self: Item): Type =
  return self.itemType

proc customized*(self: Item): bool =
  return
    self.muteAllMessages or self.personalMentions != VALUE_NOTIF_SEND_ALERTS or
    self.globalMentions != VALUE_NOTIF_SEND_ALERTS or
    self.otherMessages != VALUE_NOTIF_TURN_OFF

proc muteAllMessages*(self: Item): bool =
  return self.muteAllMessages

proc `muteAllMessages=`*(self: Item, value: bool) =
  self.muteAllMessages = value

proc personalMentions*(self: Item): string =
  return self.personalMentions

proc `personalMentions=`*(self: Item, value: string) =
  self.personalMentions = value

proc globalMentions*(self: Item): string =
  return self.globalMentions

proc `globalMentions=`*(self: Item, value: string) =
  self.globalMentions = value

proc otherMessages*(self: Item): string =
  return self.otherMessages

proc `otherMessages=`*(self: Item, value: string) =
  self.otherMessages = value
