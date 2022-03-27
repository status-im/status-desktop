import ../../../app_service/service/contacts/dto/contacts

type
  Item* = ref object
    pubKey: string
    name: string
    icon: string
    isIdenticon: bool
    isContact: bool
    isBlocked: bool
    requestReceived: bool
    trustStatus: TrustStatus

proc initItem*(pubKey, name, icon: string, isIdenticon, isContact, isBlocked, requestReceived: bool, trustStatus: TrustStatus): Item =
  result = Item()
  result.pubKey = pubKey
  result.name = name
  result.icon = icon
  result.isIdenticon = isIdenticon
  result.isContact = isContact
  result.isBlocked = isBlocked
  result.requestReceived = requestReceived
  result.trustStatus = trustStatus

proc pubKey*(self: Item): string =
  self.pubKey

proc name*(self: Item): string =
  self.name

proc `name=`*(self: Item, value: string) =
  self.name = value

proc icon*(self: Item): string =
  self.icon

proc isIdenticon*(self: Item): bool =
  self.isIdenticon

proc isContact*(self: Item): bool =
  self.isContact

proc isBlocked*(self: Item): bool =
  self.isBlocked

proc requestReceived*(self: Item): bool =
  self.requestReceived

proc `trustStatus=`*(self: Item, value: TrustStatus) =
  self.trustStatus = value

proc trustStatus*(self: Item): TrustStatus =
  self.trustStatus
