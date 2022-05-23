type
  ContactVerificationState* {.pure.} = enum
    NotMarked = 0
    Verified    
    Untrustworthy

type
  Item* = ref object
    pubKey: string
    name: string
    localNickname: string
    icon: string
    isBlocked: bool
    onlineStatus: bool
    isMutualContact: bool
    verificationState: ContactVerificationState

proc initItem*(pubKey, name, localNickname, icon: string, isMutualContact, isBlocked, onlineStatus: bool, 
  isContactVerified, isContactUntrustworthy: bool): Item =
  result = Item()
  result.pubKey = pubKey
  result.name = name
  result.localNickname = localNickname
  result.icon = icon
  result.isMutualContact = isMutualContact
  result.isBlocked = isBlocked
  result.onlineStatus = onlineStatus
  if(isContactVerified):
    result.verificationState = ContactVerificationState.Verified
  elif(isContactUntrustworthy):
    result.verificationState = ContactVerificationState.Untrustworthy
  else:
    result.verificationState = ContactVerificationState.NotMarked

proc pubKey*(self: Item): string =
  self.pubKey

proc name*(self: Item): string =
  self.name

proc localNickname*(self: Item): string =
  self.localNickname

proc `name=`*(self: Item, value: string) =
  self.name = value

proc icon*(self: Item): string =
  self.icon

proc isMutualContact*(self: Item): bool =
  self.isMutualContact

proc isBlocked*(self: Item): bool =
  self.isBlocked

proc onlineStatus*(self: Item): bool =
  self.onlineStatus

proc verificationState*(self: Item): ContactVerificationState =
  self.verificationState
